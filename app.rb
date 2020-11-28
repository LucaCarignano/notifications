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
require './controllers/TagController.rb'

# This is the main class of the system
class App < Sinatra::Base
  include FileUtils::Verbose
  
  use UserController
  use DocumentController
  use TagController

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

  post '/tags' do
    if params[:suscribe]

      user1 = User.find(id: session[:user_id])
      categories = Tag.all
      categories.each do |category|
        nombre = category.name
        next unless params[nombre]

        category.add_user(user1)
        @error = if category.save
                   'Suscripto correctamente'
                 else
                   'Error'
                 end
      end
    elsif params[:unsuscribe] && params[:tag]
      user1 = User.find(id: session[:user_id])
      user1.remove_tag(Tag.find(name: params[:tag]))
      @error = if user1.save
                 'Desuscripto correctamente'
               else
                 'Error'
               end
    end
    redirect '/tags'
  end

  post '/maketag' do
    if params[:newtag] != '' && params[:add]

      tag = Tag.find(name: params[:newtag])

      if tag
        @error = 'El tag ya existe'
        view_noti
      else
        newtag = Tag.new(name: params['newtag'])
        if newtag.save
          @succes = 'Agregado correctamente'
          view_noti
        else
          [500, {}, 'Internal server Error']
        end
      end
    elsif params[:deltag] != '' && params[:delete]

      tag = Tag.find(name: params[:deltag])

      if tag
        users_tags = Subscription.where(tag_id: tag.id)
        users_tags.each(&:delete)
        docs_tags = Category.where(tag_id: tag.id)
        docs_tags.each(&:delete)
        if tag.delete
          @succes = 'Borrado correctamente'
          view_noti
        else
          [500, {}, 'Internal server Error']
        end
      else
        @error = 'El tag no existe'
        view_noti
      end
    else
      @error = 'Inserte el nombre del tags'
      view_noti
    end
    erb :maketags, layout: :layout_main
  end

  post '/makeadmin' do
    if params[:useradmin] != ''

      useradmi = User.find(username: params[:useradmin])

      if useradmi
        useradmi.update(admin: 't')
        @succes = 'Promocion realizada'
      else
        @error = 'No existe ese usuario'
      end
    else
      @error = 'Inserte el nombre del usuario'
    end
    view_noti
    erb :makeAdmin, layout: :layout_main
>>>>>>> develop
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

  def autocompletea
    @docsname = []
    Document.where(delete: 'f').each do |doc|
      @docsname.push(doc.title)
    end
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
