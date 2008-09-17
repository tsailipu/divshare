module Divshare
  class User
    attr_reader :name, :email
    def initialize(xml)
      @name = xml.at(:user_fname).inner_html
      @email = xml.at(:user_email).inner_html
    end
    
    def to_s
      "#{@name} <#{@email}>"
    end
  end
end