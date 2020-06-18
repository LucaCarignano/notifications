require 'json'
require './models/init.rb'
require 'sinatra/base'
require 'date'
require 'tempfile'
require 'sinatra'
require 'sinatra-websocket'
include FileUtils::Verbose
 

class App < Sinatra::Base

    configure :development, :production do
        enable :logging
        enable :sessions
        set :session_secret, "una clave polenta"
        set :sessions, true
    	set :server, 'thin'
    	set :sockets, []
    end    


    before do
      if !user_logged? && restricted_path?
        redirect '/log'
      end
      if user_logged?
          @currentUser = User.find(id: session[:user_id])
          @admin = @currentUser.admin
          @path = request.path_info
          settings.sockets.each{|s| 
            @noti = (Document.where(delete: 'f', id:( Labelled.select(:document_id).where(readed: 'f', user_id: s[:user])))).count
            s[:socket].send(@noti.to_s)
            }
          if path_only_admin?
              redirect '/docs'
          end
      end
    end


    get '/' do
      if !request.websocket?
        erb :log, :layout => :layout_sig
      else
        request.websocket do |ws|
          user = session[:user_id]
          logger.info(user)
          @connection = {user: user, socket: ws}
          ws.onopen do
            settings.sockets << @connection
          end
          ws.onmessage do |msg|
            EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
          end
          ws.onclose do
            warn("websocket closed")
            settings.sockets.delete(ws)
          end
        end
      end
    end

    get "/log" do
      logger.info ""
      logger.info session["session_id"]
      logger.info session.inspect
      logger.info "-------------"
      logger.info ""
  
      if !user_logged?
        erb :log, :layout => :layout_sig
      else
        redirect '/docs'
      end
    end

    get "/adddoc" do
        @categories = Tag.all
        erb :add_doc, :layout => :layout_main
    end

      get "/login" do
          session.clear
          erb :login, :layout => :layout_sig
      end
    
    get '/view' do
      @src = params[:path]
      erb :view_doc, :layout=> false
    end

    get "/docs" do
        @documents = Document.order(:date).reverse.where(delete: 'f').all
        @categories = Tag.all
        @users = User.all
        erb :docs, :layout => :layout_main
    end

    get "/unreaddocs" do
    	user = User.find(id: session[:user_id])
    	#@documents = Document.select(:id).except(Labelled.select(:document_id).where(readed: 't', user_id: user.id))
    	@undocuments = Document.order(:date).reverse.where(delete: 'f', id:( Labelled.select(:document_id).where(readed: 'f', user_id: user.id))).all
    	@documents = Document.order(:date).reverse.where(delete: 'f', id:( Labelled.select(:document_id).where(readed: 't', user_id: user.id))).all
      erb :undocs, :layout => :layout_main
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

    get "/maketag" do
        erb :maketags, :layout => :layout_main
    end 

    get "/changeuser" do
        erb :maketags, :layout => :layout_main
    end 

    get "/tags" do
        @categories = Tag.select(:id).where(id: Subscription.select(:tag_id).where(user_id: session[:user_id]))
        @categories = Tag.where(id: @categories).all
        if @categories == []
            @errorcat = "No esta suscripto a ninguna categoria" 
        end

        @tags = Tag.select(:id).except(Subscription.select(:tag_id).where(user_id: session[:user_id]))
        @tags = Tag.where(id: @tags).all
        if @tags == []
            @errortag = "Esta suscripto a todas las categorias" 
        end

        erb :suscription, :layout => :layout_main
    end 


    get "/logout" do
        session.clear
        erb :log, :layout => :layout_sig
    end

    post "/unreaddocs" do

	    docs = Document.all
	    docs.each do |doc|
        if params[doc.location]
          reading = Labelled.find(document_id: doc.id, user_id: session[:user_id])
          if reading.readed = 'f' 
          	reading.update(readed: 't')
          end
          redirect "/view?path=#{doc.location}"
        end
	    end
    end

    post "/tags" do 

        if params[:suscribe]

            user1 = User.find(id: session[:user_id])
            categories = Tag.all
            categories.each do |category|
                nombre = category.name
				if  params[nombre]
                    category.add_user(user1)
                    if category.save
                        @error = "Succes"
                    else 
                        @error = "fail"
                    end
                end
            end
        elsif params[:unsuscribe]
        	user1 = User.find(id: session[:user_id])
            user1.remove_tag(Tag.find(name: params[:tag]))
            if user1.save
                @error = "Succes"
            else 
                @error = "fail"
            end
        end
        redirect "/tags"
    end

    post "/profile" do

        user = User.find(id: session[:user_id])

        if params[:botuser]
            @edituse = "entro"
        elsif params[:botemail]
            @editmail = "entro"
        elsif params[:botpass]
            @editpas = "entro"
        end

        if @edituse != "" && params[:editus]
            if params[:newuser] == ""
                @error = "Ingrese un nombre de usuario"
            else
                user1 = User.find(username: params[:newuser])
                if user1
                    @error = "Nombre de usuario no disponible "
                else    
                    user.update(username: params[:newuser])
                    @error = "Nombre cambiado correctamente"
                end
            end
        elsif @editmail != "" && params[:editemail]
            if params[:newemail] == ""
                @error = "Ingrese un email"
            else
                user1 = User.find(email: params[:newemail])
                if user1
                    @error = "Email ya registrado"
                else    
                    user.update(email: params[:newemail])
                    @error = "Email cambiado correctamente"
                end
            end
        elsif @editpas != "" && params[:editpass]
            if params[:newpass] == "" || params[:repas] == "" || params[:oldpass] == ""
                @error = "Ingrese contraseña"
            else
            		if params[:oldpass] != user.password
            			@error = "contraseña incorrecta"
                elsif params[:newpass] != params[:repas]
                    @error = "contraseñas distintas"
                else 
                    user.update(password: params[:newpass])
                    @error = "Contraseña cambiada correctamente"
                end
            end
        end        
        @Username = user.username
        @Email = user.email
        erb :profile, :layout => :layout_main
    end

    post "/docs" do

        if params[:datedoc] == "" && params[:tags] == "" && params[:users] == "" && params[:filter]
            redirect "/docs"
        else 

            #tagid = Tag.find(name: params[:tags])
            #userid = User.find(username: params[:users])

            #@documents = Document.association_join(:documents_tags).association_join(:document_users).where(date: params[:datedoc], tag_id: tagid.id,  user_id: userid.id)
            
        end

        documents = Document.all
        documents.each do |doc|

            location = "del"+doc.location

            if  params[location]
                doc.update(delete: 't')
            end
        end

        @documents = Document.order(:date).reverse.where(delete: 'f').all
        @categories = Tag.all
        @users = User.all
        erb :docs, :layout => :layout_main
    end

    post "/maketag" do
        if params[:newtag] != "" && params[:add]

            tag = Tag.find(name: params[:newtag])

            if tag
                @error ="Tag is already created"
                erb :maketags, :layout => :layout_main
            else
                newtag = Tag.new(name: params["newtag"])
                if newtag.save
                    @error ="Add successfully!!"
                    erb :maketags, :layout => :layout_main
                else 
                    [500, {}, "Internal server Error"]
                end
            end
        elsif params[:deltag] != "" && params[:delete]

            tag = Tag.find(name: params[:deltag])

            if tag
                if tag.delete
                    @error ="Delete successfully!!"
                    erb :maketags, :layout => :layout_main
                else 
                    [500, {}, "Internal server Error"]
                end
            else
                @error ="Tag doesn't exist"
                erb :maketags, :layout => :layout_main
            end
        else 
            @error ="Insert tag name"
            erb :maketags, :layout => :layout_main
        end
    end


    post "/makeadmin" do
        if params[:useradmin] != ""

            useradmi = User.find(username: params[:useradmin])

            if useradmi
                useradmi.update(admin: 't')
                @error ="Promoted successfully!!"
                erb :makeAdmin, :layout => :layout_main
            else
                @error ="nonexistent Username"
                erb :makeAdmin, :layout => :layout_main
            end
        else 
            @error ="Insert username"
            erb :makeAdmin, :layout => :layout_main
        end
    end

    post "/log" do
    
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


     post '/adddoc' do

        if all_field_adddoc?
            @error = "Incomplete form"
            @categories = Tag.all
            erb :add_doc, :layout => :layout_main
        else

            @filename = params[:document][:filename]
            file = params[:document][:tempfile]

            File.open("./public/file/#{@filename}", 'wb') do |f|
                f.write(file.read)
            end

            @time = Time.now.to_i
            @name =  "#{@time}#{params[:title]}".gsub(' ', '')
            @src =  "file/#{@name}.pdf"

            #request.body.rewind

            doc = Document.new(title: params["title"], date: Date.today, location: @src)
            if doc.save
              	cp(file.path, "public/#{doc.location}")    
              
            #----------- Actualizo tablas relaciones -----------#

             	labelleds = params["labelled"].split('@')
              	labelleds.each do |labelled|
                	user = User.find(username: labelled)
                	if user
                  		user.add_document(doc)
                  		user.save
               		end
              	end

                categories = Tag.all
                categories.each do |category|
                	nombre = category.name
                  
	                if params[nombre]
	                    category.add_document(doc)
	                    category.save
	                    labelled = Labelled.select(:user_id).where(document_id: doc.id)
	                    subscription = Subscription.select(:user_id).where(tag_id: category.id)
	                    users = User.where(id: subscription.except(labelled)).all
	                    users.each do |user|	          
	                    	user.add_document(doc)
	                    	user.save
	                    end
	                end
              	end



              	redirect '/docs'
            else 
              [500, {}, "Internal server Error"]
            end
            @categories = Tag.all
       		erb :add_doc, :layout => :layout_main
        end 
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
        request.path_info != '/log' && request.path_info != '/login' && request.path_info != '/rp' && request.path_info != '/docs'
    end

    def path_only_admin?
        !@currentUser.admin && ((request.path_info == '/makeadmin') || (request.path_info == '/adddoc') || (request.path_info == '/maketag'))
    end
    def all_field_register?
        (params[:username] == "" || params[:name] == "" || params[:email] == "" || params[:password] == "" || params[:surname] == "")
    end
    def all_field_adddoc?
        (params[:title] == "" || params[:labelled] == "" || params[:document] == nil)
    end


    get '/prueba' do
      if !request.websocket?
            erb :index
      else
            request.websocket do |ws|
                ws.onopen do
                    ws.send("Hello World!")
                    settings.sockets << ws
                end
                ws.onmessage do |msg|
                    EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
                end
                ws.onclose do
                    warn("websocket closed")
                    settings.sockets.delete(ws)
                end
            end
        end
    end

end