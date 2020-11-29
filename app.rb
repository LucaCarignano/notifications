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

  get '/unreaddocs' do
    user = User.find(id: session[:user_id])
    id = Labelled.select(:document_id).where(readed: 'f', user_id: user.id)
    @undocuments = Document.order(:date).reverse.where(delete: 'f', id: id).all
    id2 = Labelled.select(:document_id).where(readed: 't', user_id: user.id)
    @documents = Document.order(:date).reverse.where(delete: 'f', id: id2).all
    view_noti
    erb :undocs, layout: :layout_main
  end

  get '/makeadmin' do
    view_noti
    @users = []
    User.where(admin: 'f').each do |u|
      @users.push(u.username)
    end
    erb :makeAdmin, layout: :layout_main
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

  def view_noti
    if @current_user
      id = Labelled.select(:document_id).where(readed: 'f', user_id: @current_user.id)
      @noti = Document.where(delete: 'f', id: id).count
    end
  end
end
