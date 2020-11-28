# frozen_string_literal: true

require 'json'
require './models/init.rb'
require 'sinatra/base'
require 'date'
require 'tempfile'
require 'sinatra'
require 'sinatra-websocket'
require './controllers/UserController.rb'
require './controllers/DocumentController.rb'

# This is the main class of the system
class App < Sinatra::Base
  include FileUtils::Verbose
  
  use UserController
  use DocumentController

  before do
    UserController if !user_logged? && restricted_path?
    if user_logged?
      @current_user = User.find(id: session[:user_id])
      @admin = @current_user.admin
      @path = request.path_info
      redirect '/docs' if path_only_admin?
    end
  end

  get '/login' do
    session.clear
    erb :login, layout: :layout_sig
  end

  get '/view' do
    @src = params[:path]
    erb :view_doc, layout: false
  end

  get '/docs' do
    set_pages
    cant_pages(Document.where(delete: 'f').count)
    @documents = Document.order(:date).reverse.where(delete: 'f').limit(@docsperpage, (@page - 1) * @docsperpage)
    @categories = Tag.all
    @users = User.all
    view_noti
    erb :docs, layout: :layout_main
  end

  get '/unreaddocs' do
    user = User.find(id: session[:user_id])
    id = Labelled.select(:document_id).where(readed: 'f', user_id: user.id)
    @undocuments = Document.order(:date).reverse.where(delete: 'f', id: id).all
    id2 = Labelled.select(:document_id).where(readed: 't', user_id: user.id)
    @documents = Document.order(:date).reverse.where(delete: 'f', id: id2).all
    view_noti
    erb :undocs, layout: :layout_main
  end

  get '/applyadmin' do
    'se envia un mail a los admin para que autoricen a modificar el estado del usuario'
  end

  get '/changeuser' do
    view_noti
    erb :maketags, layout: :layout_main
  end

  get '/logout' do
    session.clear
    erb :log, layout: :layout_sig
  end

  post '/unreaddocs' do
    docs = Document.all
    docs.each do |doc|
      next unless params[doc.location]

      reading = Labelled.find(document_id: doc.id, user_id: session[:user_id])
      reading.update(readed: 't') if reading.readed == 'f'
      redirect "/view?path=#{doc.location}"
    end
  end

  post '/docs' do
    set_pages
    redirect '/docs' if not_filter?
    @documents = Document.where(delete: 'f').all
    if params[:users] != ''
      user = User.find(username: params[:users])
      if user
        aux = user.documents_dataset
        @documents &= aux.to_a
      end
    end
    if params[:tags] != ''
      tagg = Tag.find(name: params[:tags])
      if tagg
        aux2 = tagg.documents_dataset
        @documents &= aux2.to_a
      end
    end
    if params[:datedoc] != ''
      aux3 = Document.where(date: params[:datedoc]).all
      @documents &= aux3
    end
    if params[:docname] != ''
      params[:docname] = '%' + params[:docname] + '%'
      aux4 = Document.where(Sequel.like(:title, params[:docname])).all
      @documents &= aux4
    end
    cant_pages(@documents.length)
    @documents = @documents[((@page - 1) * @docsperpage)..(@page * @docsperpage) - 1]

    unless params[:filter]

      documents = Document.all
      documents.each do |doc|
        location = 'del' + doc.location
        doc.update(delete: 't') if params[location]
      end

      set_pages
      cant_pages(Document.where(delete: 'f').count)
      @documents = Document.order(:date).reverse.where(delete: 'f').limit(@docsperpage, (@page - 1) * @docsperpage)

    end
    @categories = Tag.all
    @users = User.all
    view_noti
    erb :docs, layout: :layout_main
  end

  post '/adddoc' do
    if all_field_adddoc?
      @error = 'Complete todos los campos!!'
      @categories = Tag.all
      view_noti
      erb :add_doc, layout: :layout_main
    else

      @filename = params[:document][:filename]
      file = params[:document][:tempfile]

      File.open("./public/file/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end

      @time = Time.now.to_i
      @name = "#{@time}#{params[:title]}".gsub(' ', '')
      @src = "file/#{@name}.pdf"

      # request.body.rewind

      doc = Document.new(title: params['title'], date: Date.today, location: @src)
      if doc.save
        cp(file.path, "public/#{doc.location}")

        #----------- Actualizo tablas relaciones -----------#

        users_involved = []
        labelleds = params['labelled'].split('@')
        labelleds.each do |labelled|
          user = User.find(username: labelled)
          next unless user

          users_involved << user.id
          user.add_document(doc)
          user.save
        end

        categories = Tag.all
        categories.each do |category|
          nombre = category.name

          next unless params[nombre]

          category.add_document(doc)
          category.save
          labelled = Labelled.select(:user_id).where(document_id: doc.id)
          subscription = Subscription.select(:user_id).where(tag_id: category.id)
          users = User.where(id: subscription.except(labelled)).all
          users.each do |user|
            users_involved << user.id
            user.add_document(doc)
            user.save
          end
        end

        users_notificated = []

        settings.sockets.each do |s|
          users_notificated << s if users_involved.include?(s[:user])
        end
        users_notificated.uniq
        @cant_users = settings.sockets.length
        users_notificated.each do |s|
          id = Labelled.select(:document_id).where(readed: 'f', user_id: s[:user])
          @noti = Document.where(delete: 'f', id: id).count
          s[:socket].send(@noti.to_s)
        end
        @categories = Tag.all
        view_noti
        @succes = 'Documento cargado correctamente'
        erb :add_doc, layout: :layout_main

      else
        [500, {}, 'Internal server Error']
      end
    end
  end

  post '/login' do
    # Login part
    user = User.find(username: params['us'])

    if user && user.password == params['pas']
      session[:user_id] = user.id
      redirect '/docs'
    else
      @error = 'Tu usuario o contraseña son incorrectos'
      erb :login, layout: :layout_sig
    end
  end

  def cant_pages(cantdocs)
    @docsperpage = 10
    @pagelimit = if (cantdocs % @docsperpage).zero?
                   cantdocs / @docsperpage
                 else
                   cantdocs / @docsperpage + 1
                 end
  end

  def set_pages
    @page = if params[:page]
              params[:page].to_i
            else 1
            end
  end

  def autocompletea
    @docsname = []
    Document.where(delete: 'f').each do |doc|
      @docsname.push(doc.title)
    end
  end

  def doc_users(docs_users)
    users = []
    docs_users.each { |user| users << user.username }
    users * ', '
  end

  def doc_tags(docs_tags)
    tags = []
    docs_tags.each { |tag| tags << tag.name }
    tags * ', '
  end

  def not_filter?
    params[:datedoc] == '' && params[:tags] == '' && params[:users] == '' && params[:filter] && params[:docname]
  end

  def user_logged?
    session[:user_id]
  end

  def restricted_path?
    restricted_path_aux? && request.path_info != '/log' && request.path_info != '/login'
  end

  def restricted_path_aux?
    request.path_info != '/rp' && request.path_info != '/docs' && request.path_info != '/view'
  end

  def path_only_admin?
    !@current_user.admin && request_path_admin
  end

  def request_path_admin
    ((request.path_info == '/makeadmin') || (request.path_info == '/adddoc') || (request.path_info == '/maketag'))
  end

  def all_field_register?
    (user_no_empty || params[:password] == '' || params[:surname] == '')
  end

  def user_no_empty
    (params[:username] == '' || params[:name] == '' || params[:email] == '')
  end

  def all_field_adddoc?
    (params[:title] == '' || params[:document].nil?)
  end

  def view_noti
    if @current_user
      id = Labelled.select(:document_id).where(readed: 'f', user_id: @current_user.id)
      @noti = Document.where(delete: 'f', id: id).count
    end
  end
end
