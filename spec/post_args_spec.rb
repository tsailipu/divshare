require File.dirname(__FILE__) + '/spec_helper'
require 'divshare/client'
require 'divshare/post_args'
include Divshare

module PostArgsSpecHelper
  def basic_args(to_merge={})
    {'api_key' => 'api_key', "api_sig" => 'api_sig', "api_session_key" => 'api_session_key'}.merge(to_merge)
  end
  
  def login_args(to_merge={})
    strip_key_and_sig(to_merge).merge({'method' => 'login'})
  end
  
  def logout_args(to_merge={})
    strip_key_and_sig(to_merge).merge({'method' => 'logout'})
  end
  
  def strip_key_and_sig(to_merge={})
    basic_args(to_merge).reject { |k,v| %w(api_session_key api_sig).include? k }
  end
end

describe "A PostArgs" do
  include PostArgsSpecHelper
  before(:each) do
    @client = mock('client')
    @client.should_receive(:api_key).and_return('api_key')
    @login = {'user_email' => 'email', 'user_password' => 'password'}
  end
    
  it "should generate appropriate arguments for login" do
    @client.should_receive(:api_session_key).and_return(nil)
    PostArgs.new(@client,'login',@login).should == login_args(@login)
  end
  
  it "should generate appropriate arguments for logout" do
    @client.should_receive(:api_session_key).twice.and_return('api_session_key')
    @client.should_receive(:sign).and_return('api_sig')
    PostArgs.new(@client,:logout,{}).should == basic_args({'method' => 'logout'})
  end
  
  it "should convert symbol keys to strings" do
    @client.should_receive(:api_session_key).and_return(nil)
    symbol_keys = {}
    @login.each { |k,v| symbol_keys[k.to_sym] = v }
    PostArgs.new(@client,'login',symbol_keys).should == login_args(@login)
  end
  
  it "should convert symbol values to strings" do
    @client.should_receive(:api_session_key).and_return(nil)
    PostArgs.new(@client,:login,@login).should == login_args(@login)
  end
end