require 'sinatra/base'
require './services/DocumentService'
require './exceptions/ValidationModelError.rb'

class DocumentController < Sinatra::Base

  include FileUtils::Verbose

  use UserController

  configure :development, :production do
    enable :logging
    enable :sessions
    set :views, settings.root + '/../views'
    set :session_secret, 'OHWDOI"(U$!"$"!$="UEW=DJH OHWDOI"(U$!"$"!$="UEW=DJH OHWDOI"(U$!"$"!$="UEW=DJH'
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
  end

#  get '/' do
#    if !request.websocket?
#      erb :log, layout: :layout_sig
#    else
#      request.websocket do |ws|
#        user = session[:user_id]
#        logger.info(user)
#        @connection = { user: user, socket: ws }
#        ws.onopen do
#          settings.sockets << @connection
#        end
#        ws.onclose do
#          warn('websocket closed')
#          settings.sockets.delete(ws)
#        end
#      end
#    end
#  end

  get '/adddoc' do
    @current_user = User.find(id: session[:user_id])
    @admin = @current_user.admin
    @categories = Tag.all
    @users = []
    User.each do |user|
      @users.push(user.username)
    end
    view_noti
    erb :add_doc, layout: :layout_main
  end

  post '/adddoc' do

    filename = params[:document][:filename]
    file = params[:document][:tempfile]
    title = params[:title]
    labelleds = params['labelled'].split('@')
    tags = []
    categories = Tag.all
    categories.each do |category|
      nombre = category.name
      if params[nombre]
        tags << nombre
      end
    end

    @current_user = User.find(id: session[:user_id])
    @admin = @current_user.admin
    begin 
      users_involved = DocumentService.addDocument filename, file, title, labelleds, tags
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
      return erb :add_doc, layout: :layout_main 
    rescue ArgumentError => e
      @categories = Tag.all
      view_noti
      return erb :add_doc, :locals => {:errorMessage => e.message}, layout: :layout_main
    rescue ValidationModelError => e
      @categories = Tag.all
      view_noti
      return erb :add_doc, :locals => e.errors, layout: :layout_main
    end
  end


  def view_noti
    if @current_user
      id = Labelled.select(:document_id).where(readed: 'f', user_id: @current_user.id)
      @noti = Document.where(delete: 'f', id: id).count
    end
  end
end
