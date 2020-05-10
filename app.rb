require 'json'
require './models/init.rb'
require 'sinatra/base'
include FileUtils::Verbose
 

class App < Sinatra::Base

	configure :development, :production do
		enable :logging
		enable :session
		set :session_secret, "una clave polenta"
		set :session, true
	end	

	get "/" do
		
		session.clear

	    logger.info ""
	    logger.info session["session_id"]
	    logger.info session.inspect
	    logger.info "-------------"
	    logger.info ""

		if !session[:user_id] 
			erb :log, :layout => :layout_sig
		else
			erb :docs, :layout => :layout_main
		end
	end

	get "/adddoc" do
		erb :add_doc, :layout => :layout_main
	end
	
	post "/" do

		session.clear

		# Login part
		user1 = User.find(username: params[:user])
		
      	if user1 && user1.password == params[:pass]
        	session[:user_id] = user1.id
        	redirect "/docs"
      	elsif params["user"] != ""
      		@error ="Your username o password is incorrect"
        	redirect "/login"

		# Register to the system part
		elsif User.find(username: params[:username])
		    @error = "The username is already taken!!"
		    erb :log, :layout => :layout_sig
		elsif   User.find(email: params[:email])                                                                                               
		    @error = "The email have a user created!!"
		    erb :log, :layout => :layout_sig
		elsif params[:password].length < 9
		    @error = "Password must have more than 8 caracters!!"
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

	    doc = Document.new(title: params["title"], date: params["date"], tags: params["tags"], labelled: params["labelled"])
	    if doc.save
	      "redirect home"
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
