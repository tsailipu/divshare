require File.dirname(__FILE__) + '/spec_helper'
require 'divshare/user'
include Divshare

describe "A basic User" do
  include DivshareMockXML
  before(:each) do 
    @xml = Hpricot(get_user_info_xml)#.at(:user_info)
  end
  
  it "should set instance variables at creation" do
    user = User.new(@xml)
    user.name.should == 'Rob'
    user.email.should == 'support@divshare.com'
  end

    
end