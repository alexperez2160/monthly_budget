ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "fileutils"
require "bcrypt"

require_relative "../budget"

class AppTest < Minitest::Test 
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end 

  def session
  	last_request.env["rack.session"]
  end
  
  def admin_session
  	{ "rack.session" => { username: "admin" } }
	end

	def test_index
	  get "/"

	    assert_equal 200, last_response.status
	    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
	    assert_includes last_response.body, "Welcome"
	end 
	
	def test_sign 
	  get "/user/signin"
	  
	  assert_equal 200, last_response.status 
	  assert_includes last_response.body, "Username"
	end 
	
  def test_signin
    post "/user/signin", username: "ale", password: "enter"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_includes session[:user], "ale"
  end
  

  def test_signout
    post "/user/signout" 
    assert_equal 302, last_response.status
    
    get last_response["Location"]
    assert_includes last_response.body, "signed out" 
  end 
  
  def test_edit
    get "/edit"
    
    assert_equal 200, last_response.status
    assert_includes last_response.body, "Submit"
  end 
  
  def test_submit_edits
    post "/update"
    
    
    assert_equal 302, last_response.status
    get last_response["Location"]
    assert_includes last_response.body, "500"
    
  end 
    
end 