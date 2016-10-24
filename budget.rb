require "yaml"
require "sinatra"
require "sinatra/reloader" 
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"
require "bcrypt"


configure do 
	enable :sessions 
	set :session_secret, 'secret'
end 

def load_user_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
  YAML.load_file(credentials_path)
end

def data_path 
	if ENV["RACK_ENV"] == "test"
		File.expand_path("../test", __FILE__)
	else 
		File.expand_path("../", __FILE__)
	end 
end 

get "/" do
  
  erb :index, layout: :layout 
end 

get '/user/signin' do 

	erb :signin, layout: :layout
end 

post "/user/signin" do 
 @username = params[:username].strip
	@password = params[:password].strip

	@credentials = load_user_credentials


	bcrypt_password = BCrypt::Password.new(@credentials.fetch("password"))

	
	if @credentials.fetch("username") == @username && bcrypt_password == @password
	  session[:user] = @username
    session[:income] = @credentials.fetch("income")
    session[:expense] = @credentials.fetch("expenses")
    
    session[:success] = "#{@username} signed in successfully"
   
    redirect "/"
	else 
		session[:error] = "Incorrect username or password"
		status 422
		erb :signin, layout: :layout 
	end 
end 

post "/user/signout" do 
	session[:success] = "#{session[:user]} has been signed out."
	session[:user] = nil  

	redirect "/"

end 

get "/edit" do
  
  erb :edit, layout: :layout 
end 

post "/update" do 
  
  session[:income]= params[:income].to_i
  session[:expense] = params[:expenses].to_i
 
  @credentials = load_user_credentials
  @credentials["income"] = session[:income]
  @credentials["expenses"] = session[:expense]
  
  @file_path = File.join(data_path, "users.yml")
  File.open(@file_path, 'w') { |f| YAML.dump(@credentials, f) }
  
  redirect "/"
  
end 

		
		
		