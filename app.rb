require 'json'
require './models/init.rb'
require 'sinatra/base'
require 'date'
require 'tempfile'
include FileUtils::Verbose
 

class App < Sinatra::Base

	configure :development, :production do
		enable :logging
		enable :sessions
		set :session_secret, "una clave polenta"
		set :sessions, true
	end	


	before do
      if !user_logged? && restricted_path?
        redirect '/'
      end
      if user_logged?
      	@currentUser = User.find(id: session[:user_id])
      	@admin = @currentUser.admin
      	if path_only_admin?
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

  	get "/login" do
  		session.clear
  		erb :login, :layout => :layout_sig
  	end
	
	get '/view/:doc_location' do
		@src = "/file/" + params[:doc_location] + ".pdf"
		erb :view_doc, :layout=> false
	end

	get "/docs" do
		@documents = Document.order(:date).reverse.all
  		erb :docs, :layout => :layout_main
  	end

	get "/rp" do
		erb :rp, :layout => :layout_sig
	end

	get "/profile" do
		user = User.find(id: session[:user_id])
		@Username = user.username
		@Email = user.email
		erb :profile, :layout => :layout_main
	end 

	get "/applyadmin" do
		"se envia un mail a los admin para que autoricen a modificar el estado del usuario"
	end 

	get "/makeadmin" do
		erb :makeAdmin, :layout => :layout_main
	end 

	get "/logout" do
		session.clear
		erb :log, :layout => :layout_sig
	end

	post "/makeadmin" do
		if params[:useradmin] != ""

			useradmin = User.find(username: params[:useradmin])

			if useradmin
				useradmin.update(admin: 't')
			else
				@error ="nonexistent Username"
	        	redirect "/makeadmin"
	        end
	    else 
			erb :makeadmin, :layout => :layout_main
		end
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
		if all_field_register?
			@error = "Incomplete form"
		end
		if User.find(username: params[:username])
		    @errorUser = "The username is already taken!!"
		end
		if   User.find(email: params[:email])                                                                                               
		    @errorEmail = "The email have a user created!!"
		end
		if params[:password].length < 6
		    @errorPassLength = "Password must have more than 5 caracters!!"
		end
		if params[:password] != params[:password2]
		    @errorPassDif = "Passwords are diferent!!"
		end		    
		if !@errorPassLength && !@errorUser && !@error && !@errorEmail && !@errorPassDif

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
		else 
			erb :log, :layout => :layout_sig
		end
	end
	
	#Comprobar que el mail se encuentre en la base de datos
	post "/rp" do
		if params[:email]=="Fede@gmail" 
			    "se a enviado un correo a tu mail con la nueva contraseña provisoria"
		else "email inválido"
		end
	end

	get "/prueba" do

		file = Tempfile.new.binmode
		begin
		  file.write <<~FILE
		    Test data
		    test data
		  FILE
		  file.close
		  puts IO.read(file.path) #=> Test data\ntestdata\n
		end	

		cp(file.path, "public/file/pruebaTest.pdf")	
	end

 	post '/adddoc' do

	    if params[:title] == ""  || params[:tag] == "" || params[:labelled] == "" || params[:document] == ""  
	    	@error = "Incomplete form"
	    end

	    file = Tempfile.new.binmode
		begin
		  file.write {params[:document]}
		  file.close
		  puts IO.read(file.path) #=> Test data\ntestdata\n
		end	

		cp(file.path, "public/file/pruebasolo.pdf")	

	    #file = Tempfile.create { |f| f << "Viva la patriaaa!!!" }
	    #file = Tempfile.new(params[:document])
	    #@time = Time.now	    
	    #@name =  "#{@time}#{params[:title]}"
	    #@src =  "/file/#{@name}"

	   #request.body.rewind
	    #hash = Rack::Utils.parse_nested_query(request.body.read)
	    #params = JSON.parse hash.to_json 

	    #doc = Document.new(title: params["title"], date: Date.today, tags: params["tags"], labelled: params["labelled"], location: @src)
	    #if doc.save
	    #  cp(file.path, "public/file/#{@name}.pdf")	
	    #  redirect '/docs'
	    #else 
	    #  [500, {}, "Internal server Error"]
	    #end 
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

	def user_logged?
    	session[:user_id]
	end

	def restricted_path?
		request.path_info != '/' && request.path_info != '/login' && request.path_info != '/rp' && request.path_info != '/' && request.path_info != '/docs'
	end

	def path_only_admin?
		!@currentUser.admin && (request.path_info == '/adddoc' || request.path_info == '/makeadmin')
	end
	def all_field_register?
		(params[:username] == "" || params[:name] == "" || params[:email] == "" || params[:password] == "" || params[:surname] == "")
	end

end