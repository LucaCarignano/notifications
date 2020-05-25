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
        @documents = Document.order(:date).reverse.all
        @categories = Tag.all
        @users = User.all
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

    get "/maketag" do
        erb :maketags, :layout => :layout_main
    end 

    get "/changeuser" do
        erb :maketags, :layout => :layout_main
    end 

    get "/logout" do
        session.clear
        erb :log, :layout => :layout_sig
    end

    post "/profile" do

        "#{params[:edituser]}"
        "#{params[:editemail]}"
        "#{params[:editpass]}"
        "algo imprimo"

    end

    post "/docs" do

        if params[:datedoc] == "" && params[:tags] == "" && params[:users] == "" && params[:filter]
            redirect "/docs"
        else 

            tagid = Tag.find(name: params[:tags])
            userid = User.find(username: params[:users])

            @documents = Document.association_join(:documents_tags).association_join(:document_users).where(date: params[:datedoc], tag_id: tagid.id,  user_id: userid.id)
            
        end

        #if params[:delfile]

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


     post '/adddoc' do

        @filename = params[:document][:filename]
        file = params[:document][:tempfile]

        File.open("./public/file/#{@filename}", 'wb') do |f|
            f.write(file.read)
        end

        @time = Time.now.to_i
        @name =  "#{@time}#{params[:title]}".gsub(' ', '')
        @src =  "file/#{@name}.pdf"

        request.body.rewind

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
            if params[:nombre] != ""

                category.add_document(doc)
                category.save
            end
          end
          redirect '/docs'
        else 
          [500, {}, "Internal server Error"]
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
        request.path_info != '/' && request.path_info != '/login' && request.path_info != '/rp' && request.path_info != '/' && request.path_info != '/docs'
    end

    def path_only_admin?
        !@currentUser.admin && ((request.path_info == '/makeadmin') || (request.path_info == '/adddoc') || (request.path_info == '/maketag'))
    end
    def all_field_register?
        (params[:username] == "" || params[:name] == "" || params[:email] == "" || params[:password] == "" || params[:surname] == "")
    end

end