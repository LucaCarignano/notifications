require 'json'
require './models/init.rb'
require 'sinatra/base'
 

class App < Sinatra::Base

	configure :development, :production do
		enable :logging
		enable :session
		set :session_secret, "secret"
		set :session, true
	end	

	get "/" do
		logger.info "params"
		logger.info session[:user_id]
		logger.info "--------------"

		logger.info session.inspect
		logger.info "Configurations"
		#logger.info settings.db.adapter
		logger.info "--------------"

    	erb :log, :layout => :layout_sig
	end

	get "/adddoc" do
		erb :add_doc, :layout => :layout_main
	end
	
	#Comprobar que el usuario y la contraseña sean del mismo user y se encuentre en
	#la base de datos, si no, informar que se han ingresado datos inválidos
	post "/" do

		if User.last.id
			session[:user_id] = User.last.id

			[200, {"Content-Type" => "text/plain"}, ["You're logged in"]]
		else
			# halt 401, 'go away!'      
			[400, {"Content-Type" => "text/plain"}, ["Unautorized"]]
		end


		request.body.rewind

		hash = Rack::Utils.parse_nested_query(request.body.read)
		params = JSON.parse hash.to_json 

		user = User.new(name: params["name"], email: params["email"], username: params["username"], password: params["password"])
		if user.save
		  "redirect home"
		else 
		  [500, {}, "Internal server Error"]
		end 
	end
			#if params[:user]=="asd" && params[:pass] == "asd" 
			#	    "funciona"
			#else 
			#	@error = 'Username or password was incorrect'
		 	#	erb :log			
			#end


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
		@documents = Doc.all
  		erb :docs, :layout => :layout_main
  	end

 	post '/adddoc' do
	    request.body.rewind

	    hash = Rack::Utils.parse_nested_query(request.body.read)
	    params = JSON.parse hash.to_json 

	    doc = Doc.new(title: params["title"], date: params["date"], tags: params["tags"], labelled: params["labelled"])
	    if doc.save
	      "redirect home"
	    else 
	      [500, {}, "Internal server Error"]
	    end 
  	end 

end
