require 'json'
require './models/init.rb'

class App < Sinatra::Base
	
	get "/" do
    	erb :log, :layout => :layout_sig
	end

	get "/adddoc" do
		erb :add_doc, :layout => :layout_sig
	end
	
	#Comprobar que el usuario y la contraseña sean del mismo user y se encuentre en
	#la base de datos, si no, informar que se han ingresado datos inválidos
	post "/" do
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
  		erb :docs, :layout => :layout_sig
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
