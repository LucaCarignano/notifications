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
        #@noti = (Document.where(delete: 'f', id:( Labelled.select(:document_id).where(readed: 'f', user_id: @currentUser.id)))).count
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
      @users = []
      User.each do |user| 
        @users.push(user.username)
      end
      get_noti
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

    def cant_pages(cantdocs)
      @docsperpage = 10
      if cantdocs % @docsperpage == 0
        @pagelimit = cantdocs / @docsperpage 
      else
        @pagelimit = cantdocs / @docsperpage + 1
      end
    end

    def set_pages
      if params[:page]
        @page = params[:page].to_i
      else @page = 1
      end
    end

    def autocompleteDocs
      @docsname = []
      Document.each do |doc|
        @docsname.push(doc.title)
      end
    end

    get "/docs" do
      set_pages
      cant_pages(Document.where(delete: 'f').count)
      autocompleteDocs
      @documents = Document.order(:date).reverse.where(delete: 'f').limit(@docsperpage, @page*@docsperpage-(@docsperpage-1))
      @categories = Tag.all
      @users = User.all
      get_noti
      erb :docs, :layout => :layout_main
    end

    get "/unreaddocs" do
      user = User.find(id: session[:user_id])
      @undocuments = Document.order(:date).reverse.where(delete: 'f', id:( Labelled.select(:document_id).where(readed: 'f', user_id: user.id))).all
      @documents = Document.order(:date).reverse.where(delete: 'f', id:( Labelled.select(:document_id).where(readed: 't', user_id: user.id))).all
      get_noti
      erb :undocs, :layout => :layout_main
    end

    get "/rp" do
      erb :rp, :layout => :layout_sig
    end

    get "/profile" do
      user = User.find(id: session[:user_id])
      @Username = user.username
      @Email = user.email
      get_noti
      erb :profile, :layout => :layout_main
    end 

    get "/applyadmin" do
      "se envia un mail a los admin para que autoricen a modificar el estado del usuario"
    end 

    get "/makeadmin" do
      get_noti
      erb :makeAdmin, :layout => :layout_main
    end 

    get "/maketag" do
      get_noti
      erb :maketags, :layout => :layout_main
    end 

    get "/changeuser" do
      get_noti
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
      get_noti
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
          if params[nombre]
            category.add_user(user1)
            if category.save
              @error = "Suscripto correctamente"
            else 
              @error = "Error"
            end
          end
        end
      elsif params[:unsuscribe]
        user1 = User.find(id: session[:user_id])
        user1.remove_tag(Tag.find(name: params[:tag]))
        if user1.save
          @error = "Suscripto correctamente"
        else 
          @error = "Error"
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
      get_noti
      erb :profile, :layout => :layout_main
    end

    post "/docs" do
      set_pages
      autocompleteDocs
      if params[:datedoc] == "" && params[:tags] == "" && params[:users] == "" && params[:filter]
          redirect "/docs"
      end      
      @documents = Document.all
      if params[:users] != ""
        user = User.find(username: params[:users])
        if user
          aux = user.documents_dataset
          @documents = @documents & aux.to_a
        end  
      end
      if params[:tags] != ""
        tagg = Tag.find(name: params[:tags])
        if tagg
          aux2 = tagg.documents_dataset
          @documents = @documents & aux2.to_a
        end       
      end
      if params[:datedoc] != ""
        aux3 = Document.where(date: params[:datedoc]).all
        @documents = @documents & aux3
      end
      if params[:docname] && params[:docname] != ""
        aux4 = Document.where(title: params[:docname]).all       
        @documents = @documents & aux4
      end
      cant_pages(@documents.length)
      @documents = @documents[((@page - 1) * @docsperpage) ..  (@page * @docsperpage)-1]    

      if !params[:filter]

        documents = Document.all
        documents.each do |doc|

          location = "del"+doc.location
          if  params[location]
            doc.update(delete: 't')
          end
        end

        @documents = Document.order(:date).reverse.where(delete: 'f').all

      end
      @categories = Tag.all
      @users = User.all
      get_noti
      erb :docs, :layout => :layout_main
    end

    post "/maketag" do
      if params[:newtag] != "" && params[:add]

        tag = Tag.find(name: params[:newtag])

        if tag
            @error ="El tag ya existe"
            get_noti
            erb :maketags, :layout => :layout_main
        else
          newtag = Tag.new(name: params["newtag"])
          if newtag.save
            @succes ="Agregado correctamente"
            get_noti
            erb :maketags, :layout => :layout_main
          else 
            [500, {}, "Internal server Error"]
          end
        end
      elsif params[:deltag] != "" && params[:delete]

        tag = Tag.find(name: params[:deltag])

        if tag
          if tag.delete
            @succes ="Borrado correctamente"
            get_noti
            erb :maketags, :layout => :layout_main
          else 
            [500, {}, "Internal server Error"]
          end
        else
          @error ="El tag no existe"
          get_noti
          erb :maketags, :layout => :layout_main
        end
      else 
        @error ="Inserte el nombre del tags"
        get_noti
        erb :maketags, :layout => :layout_main
      end
    end


    post "/makeadmin" do
      if params[:useradmin] != ""

        useradmi = User.find(username: params[:useradmin])

        if useradmi
          useradmi.update(admin: 't')
          @succes ="Promocion realizada"
          get_noti
          erb :makeAdmin, :layout => :layout_main
        else
          @error ="No existe ese usuario"
          get_noti
          erb :makeAdmin, :layout => :layout_main
        end
      else 
        @error ="Inserte el nombre del usuario"
        get_noti
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
          @error ="Tu usuario o contraseña son incorrectos"
          redirect "/login"
        end
      end

      # Register to the system part
      if all_field_register?
        @error = "Complete todos los campos!!"
      end
      if User.find(username: params[:username])
        @errorUser = "El nombre de usario ya esta registrado!!"
      end
      if User.find(email: params[:email])                                                                                               
        @errorEmail = "El email ya esta registrado!!"
      end
      if params[:password].length < 6
        @errorPassLength = "La contraseña tiene que tener mas de 5 caracteres!!"
      end
      if params[:password] != params[:password2]
        @errorPassDif = "Las contraseñas son diferentes!!"
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

    post '/adddoc' do

      if all_field_adddoc?
        @error = "Complete todos los campos!!"
        @categories = Tag.all
        get_noti
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

          usersInvolved = Array.new()
          labelleds = params["labelled"].split('@')
          labelleds.each do |labelled|
            user = User.find(username: labelled)
            if user
              usersInvolved << user.id
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
                usersInvolved << user.id            
                user.add_document(doc)
                user.save
              end
            end
          end

          usersNotificated = Array.new()

          settings.sockets.each { |s|
            if (usersInvolved.include?(s[:user]))
              usersNotificated << s
            end
          }
          usersNotificated.uniq
          @cantUsers = settings.sockets.length
          usersNotificated.each{|s|
            @noti = (Document.where(delete: 'f', id:(Labelled.select(:document_id).where(readed: 'f', user_id: s[:user])))).count
            s[:socket].send(@noti.to_s)
          }
          @categories = Tag.all
          get_noti
          erb :add_doc, :layout => :layout_main
            
        else 
          [500, {}, "Internal server Error"]
        end
      end 
    end 

    post "/login" do

      # Login part
      user = User.find(username: params["us"])
      
      if user && user.password == params["pas"]
        session[:user_id] = user.id
        redirect "/docs"
      else
        @error ="Tu usuario o contraseña son incorrectos"
        erb :login, :layout => :layout_sig
      end
    end

    def doc_users( docsUsers)
      users = Array.new()
      docsUsers.each { |user| users <<user.username }
      return users * ", " 
    end

    def doc_tags( docsTags)
      tags = Array.new()
      docsTags.each { |tag| tags <<tag.name }
      return tags * ", " 
    end

    def user_logged?
      session[:user_id]
    end

    def restricted_path?
      request.path_info != '/log' && request.path_info != '/login' && request.path_info != '/rp' && request.path_info != '/docs' && request.path_info != '/prueba'
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

    def get_noti
      if @currentUser
        @noti = (Document.where(delete: 'f', id:( Labelled.select(:document_id).where(readed: 'f', user_id: @currentUser.id)))).count
      end
    end

    get "/prueba" do
      erb :index, :layout => false
    end
end