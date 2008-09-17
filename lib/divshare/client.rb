require 'cgi'
require 'net/http'
require 'hpricot'
require 'digest/md5'
require 'divshare/multipart'

module Divshare
  class Client
    
    API_URL = 'http://www.divshare.com/api/'
    UPLOAD_URL = 'http://upload.divshare.com'
    UPLOAD_PATH = '/api/upload'
    
    SUCCESS = '1'
    FAILURE = '0'
  
    attr_reader :api_key, :api_secret, :api_session_key
    attr_accessor :debug # If true, extended debugging information is printed

    def initialize(api_key, api_secret, session_key=nil)
      @api_key, @api_secret, @api_session_key = api_key, api_secret, session_key
    end

    def login(email, password)
      logout if @api_session_key
      response = send_method(:login, {'user_email' => email, 'user_password' => password})
      @api_session_key = response.at(:api_session_key).inner_html
    end

    # Returns true if logout is successful. 
    def logout
      response = send_method(:logout)
      if response.at(:logged_out).inner_html == '1'
        @api_session_key = nil
        true
      else
        false
      end
    end


    # file_ids should be an array of file ids
    # def get_files(file_ids)
    #   file_ids = [file_ids] unless file_ids.respond_to?(:join)
    #   response = send_method(:get_files, 'files' => file_ids.join(','))
    #   files_from response
    # end

    # This method replaces the real get_files until the API is cleared up and
    # working properly. Limitation: it can only retrieve files owned by the
    # logged-in user.
    def get_files(file_ids)
      file_ids = [file_ids] unless file_ids.is_a? Array
      debug "DivShare.get_files(): #{file_ids.class}"
      files = get_user_files
      files.delete_if {|f| file_ids.include?(f.file_id) == false}
    end
    
    # A convenience method for finding only one file. Returns a single
    # DivshareFile instead of an array.
    def get_file(file_id)
      raise ArgumentError, "Only one file id allowed for this method" if file_id.is_a?(Array)
      get_files(file_id).first
    end

    def get_user_files(limit=nil, offset=nil)
      args = {}
      args['limit'] = limit unless limit.nil?
      args['offset'] = offset unless offset.nil?
      response = send_method(:get_user_files, args)
      files_from(response)
    end

    def get_user_info
      response = send_method(:get_user_info)
      user_from(response)
    end

    def get_upload_ticket
      send_method(:get_upload_ticket).at(:upload_ticket).inner_html
    end

    # response_url is just a filler so that the server doesn't complain
    # (if DivShare supports direct uploading, we needn't do this)
    # specify it is nice nevertheless so that perhaps DivShare knows the caller on their end
    def upload(ticket, file_path, response_url='www.divshare.com/upload_result')      
      location = nil
      File.open(file_path, 'r') { |file|
        uri = URI.parse(UPLOAD_URL)
        http = Net::HTTP.new(uri.host, uri.port)
        # API methods can be SLOW.  Make sure this is set to something big to prevent spurious timeouts
        http.read_timeout = 15*60
        request = Net::HTTP::Post.new(UPLOAD_PATH)
        fields = Hash.new
        fields['upload_ticket'] = ticket
        fields['response_url'] = response_url   # just a filler because this cannot be blank but it has no use in this situation

        fields['file1'] = file
        request.multipart_params = fields
        # Until DivShare supports direct upload API, we deal with its response location field
        location = http.request(request)['location']
      }
      
      # if error, throw, otherwise return file ID for caller to do whatever they like
      resp = {}
      location.split('?')[1].split('&').each { |param| 
        k, v = param.split('=', 2)  # some params could contain two '=' for some reason
        resp[k]=CGI.unescape(v)
      }
      if resp['error']
        raise Divshare::APIError, resp['description']
      else
        resp['file1']   # return the file ID
      end
    end
    

    # Since login and logout aren't easily re-nameable to use method missing
    def send_method(method_id, *params)
      response = http_post(method_id, *params)
      xml = Hpricot(response).at(:response)
      if xml[:status] == FAILURE
        errors = (xml/:error).collect {|e| e.inner_html}
        raise Divshare::APIError, errors.join("\n")
      end
      xml
    end


    private
    
    def files_from(xml)
      xml = xml/:file
      xml = [xml] unless xml.respond_to?(:each)    
      files = xml.collect { |f| DivshareFile.new f }
    end
    
    def user_from(xml)
      xml = xml.at(:user_info)
      Divshare::User.new(xml)
    end
    
    def http_post(method, args={})
      url = URI.parse(API_URL)
      tries = 3
      response = ""
      form_args = post_args(method, args)
      begin
        response = Net::HTTP.post_form(url, form_args).body
      rescue
        tries -= 1
          debug "DivShare.http_post(): Tries == '#{tries}'"
        if tries > 0
          retry
        else
          raise Divshare::ConnectionError, "Couldn't connect for '#{method}' using #{form_args}"
        end
      end
      response
    end
   
    def post_args(method, args)
      all_args = args.merge({'method' => method, 'api_key' => api_key})
      if @api_session_key #&& method.to_sym != :logout
        api_sig = sign(all_args)
        all_args.merge!({'api_session_key' => @api_session_key, 'api_sig' => api_sig})
      end
      str_args = {}
      all_args.each { |k,v| str_args[k.to_s] = v.to_s }
      str_args
    end
 
    
    def sign(args)
      Digest::MD5.hexdigest(string_to_sign(args))
    end
    
    # From http://www.divshare.com/integrate/api
    #
    # * Your secret key is 123-secret. 
    # * Your session key is 456-session. 
    # * You are using the get_user_files method, and you're sending the
    #   parameters limit=5 and offset=10.
    #
    # The string used to create your signature will be:
    # 123-secret456-sessionlimit5offset10. Note that the parameters must be in
    # alphabetical order, so limit always comes before offset. Each parameter
    # should be paired with its value as shown.
    def string_to_sign(args)
      args_for_string = args.dup.delete_if {|k,v| %w(api_key method api_sig api_session_key).include?(k) }
      "#{@api_secret}#{@api_session_key}#{args_for_string.to_a.sort.flatten.join}"
    end
    
    # Outputs whatever is given to $stderr if debugging is enabled.
    def debug(*args)
      $stderr.puts(sprintf(*args)) if @debug
    end
  end
end
