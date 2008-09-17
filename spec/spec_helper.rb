lib_path = File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift(lib_path) unless $:.include?(lib_path)

# From http://www.divshare.com/integrate/api
module DivshareMockXML
  def get_user_info_xml
    <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <response status="1">
        <user_info>
            <user_fname>Rob</user_fname>
            <user_email>support@divshare.com</user_email>
        </user_info>
    </response>
    EOS
  end
  
  def get_one_file_xml
    <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <response status="1">
        <files>
            <file>
                <file_id>123456-abc</file_id>
                <file_name>My Resume.doc</file_name>
                <file_description>Resume (Draft 3)</file_description>
                <file_size>0.4 MB</file_size>
                <downloads>4</downloads>
                <last_downloaded_at>1192417863</last_downloaded_at>
                <uploaded_at>1192454938</uploaded_at>
                <folder_title>Job Applications</folder_title>
                <folder_id>12345</folder_id>
            </file>
        </files>
    </response>
    EOS
  end
  
  def get_two_files_xml
    <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <response status="1">
        <files>
            <file>
                <file_id>123456-abc</file_id>
                <file_name>My Resume.doc</file_name>
                <file_description>Resume (Draft 3)</file_description>
                <file_size>0.4 MB</file_size>
                <downloads>4</downloads>
                <last_downloaded_at>1192417863</last_downloaded_at>
                <uploaded_at>1192454938</uploaded_at>
                <folder_title>Job Applications</folder_title>
                <folder_id>12345</folder_id>
            </file>
            <file>
                <file_id>456789-def</file_id>
                <file_name>My Audio Resume.mp3</file_name>
                <file_description>Resume (Draft 3)</file_description>
                <file_size>4.4 MB</file_size>
                <downloads>40</downloads>
                <last_downloaded_at>1192817863</last_downloaded_at>
                <uploaded_at>1192464938</uploaded_at>
                <folder_title>Job Applications</folder_title>
                <folder_id>12345</folder_id>
            </file>
        </files>
    </response>
    EOS
  end
  
  def get_three_files_xml
    <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <response status="1">
        <files>
            <file>
                <file_id>123456-abc</file_id>
                <file_name>My Resume.doc</file_name>
                <file_description>Resume (Draft 3)</file_description>
                <file_size>0.4 MB</file_size>
                <downloads>4</downloads>
                <last_downloaded_at>1192417863</last_downloaded_at>
                <uploaded_at>1192454938</uploaded_at>
                <folder_title>Job Applications</folder_title>
                <folder_id>12345</folder_id>
            </file>
            <file>
                <file_id>456789-def</file_id>
                <file_name>My Audio Resume.mp3</file_name>
                <file_description>Resume (Draft 3)</file_description>
                <file_size>4.4 MB</file_size>
                <downloads>40</downloads>
                <last_downloaded_at>1192817863</last_downloaded_at>
                <uploaded_at>1192464938</uploaded_at>
                <folder_title>Job Applications</folder_title>
                <folder_id>12345</folder_id>
            </file>
            <file>
                <file_id>789123-ghi</file_id>
                <file_name>My Video Resume.mov</file_name>
                <file_description>Resume (Draft 3)</file_description>
                <file_size>14.4 MB</file_size>
                <downloads>44</downloads>
                <last_downloaded_at>1192817864</last_downloaded_at>
                <uploaded_at>1192464939</uploaded_at>
                <folder_title>Job Applications</folder_title>
                <folder_id>12345</folder_id>
            </file>          
        </files>
    </response>
    EOS
  end

  def login_xml
    <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <response status="1">
        <api_session_key>123-abcdefghijkl</api_session_key>
    </response>
    EOS
  end
  
  def logout_xml
    <<-EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <response status="1">
        <logged_out>true</logged_out>
    </response>
    EOS
  end
  
end



