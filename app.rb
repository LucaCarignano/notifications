require 'json'
require './models/init.rb'
require 'sinatra/base'
include FileUtils::Verbose
 

class App < Sinatra::Base

	configure :development, :production do
		enable :logging
		enable :sessions
		set :session_secret, "una clave polenta"
		set :sessions, true
	end	


	before do
      if !session[:user_id] && request.path_info != '/' && request.path_info != '/docs'
        redirect '/'
      end
      if session[:user_id]
      	@currentUser = User.find (id: session[:user_id])
      	#@visibility = currentUser.admin ? "inline" : "none"
      	if !currentUser.admin && request.path_info == '/adddoc'
      		redirect '/docs'
      	end
      end
	end

	get "/" do
      logger.info ""
      logger.info session["session_id"]
      logger.info session.inspect
      logger.info "-------------"
      logger.info ""
  
	  if !session[:user_id]
	  	erb :log, :layout => :layout_sig
	  else
	    redirect '/docs'
	  end
	end

	get "/adddoc" do
		erb :add_doc, :layout => :layout_main
	end
	
	post "/" do

		
		# Login part
		if params[:Login]
			user1 = User.find(username: params[:user])
			
	      	if user1 && user1.password == params[:pass]
	        	session[:user_id] = user1.id
	        	redirect "/docs"
	      	elsif !user1 || params[:user] == "" || params[:pass] == "" || user1.password != params[:pass]
	      		@error ="Your username o password is incorrect"
	        	redirect "/login"
	        end
    	end

		# Register to the system part
		if (params[:username] == "" || params[:name] == "" || params[:email] == "" || params[:password] == "")
			@error = "Incomplete form"
			erb :log, :layout => :layout_sig
		elsif User.find(username: params[:username])
		    @error = "The username is already taken!!"
		    erb :log, :layout => :layout_sig
		elsif   User.find(email: params[:email])                                                                                               
		    @error = "The email have a user created!!"
		    erb :log, :layout => :layout_sig
		elsif params[:password].length < 6
		    @error = "Password must have more than 5 caracters!!"
		    erb :log, :layout => :layout_sig
		elsif params[:password] != params[:password2]
		    @error = "Passwords are diferent!!"
		    erb :log, :layout => :layout_sig
		else
	        request.body.rewind

	        hash = Rack::Utils.parse_nested_query(request.body.read)
	        params = JSON.parse hash.to_json 
	        user = User.new(name: params["name"], surname: params["surname"], email: params["email"], username: params["username"], password: params["password"])
	        if user.save
	           session[:user_id] = user.id
	           redirect "/docs"
	           
	        else 
		        [500, {}, "Internal server Error"]
		    end
		end
	end

	get "/logout" do
		session.clear
		erb :log, :layout => :layout_sig
	end

	get "/rp" do
		erb :rp, :layout => :layout_sig
	end
	
	#Comprobar que el mail se encuentre en la base de datos
	post "/rp" do
		if params[:email]=="Fede@gmail" 
			    "se a enviado un correo a tu mail con la nueva contraseña provisoria"
		else "email inválido"
		end
	end

	get "/docs" do
		@documents = Document.all
  		erb :docs, :layout => :layout_main
  	end

 	post '/adddoc' do
	    request.body.rewind
	    hash = Rack::Utils.parse_nested_query(request.body.read)
	    params = JSON.parse hash.to_json 

	    if params["title"] == ""  && params["tag"] == "" && params["document"] == ""
	    	@error = "Incomplete form"

	    doc = Document.new(title: params["title"], date: params["date"], tags: params["tags"], labelled: params["labelled"])
	    if doc.save
	      redirect '/docs'
	    else 
	      [500, {}, "Internal server Error"]
	    end 
  	end 

  	get "/login" do
  		session.clear
  		erb :login, :layout => :layout_sig
  	end

  	post "/login" do

		# Login part
		user = User.find(username: params["us"])
		
      	if user && user.password == params["pas"]
        	session[:user_id] = user.id
        	redirect "/docs"
      	else
      		@error ="Your username o password is incorrect"
        	erb :login, :layout => :layout_sig
      	end

  	end	
end
