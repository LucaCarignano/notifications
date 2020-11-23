require 'sinatra/base'
require './services/UserService'
require './exceptions/ValidationModelError.rb'

class UserController < Sinatra::Base

  include FileUtils::Verbose

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
    @categories = Tag.all
    @users = []
    User.each do |user|
      @users.push(user.username)
    end
    view_noti
    erb :add_doc, layout: :layout_main
  end

  post '/adddoc' do
    if all_field_adddoc?
      @error = 'Complete todos los campos!!'
      @categories = Tag.all
      view_noti
      erb :add_doc, layout: :layout_main
    else

      filename = params[:document][:filename]
      file = params[:document][:tempfile]
      title = params[:title]

      begin 
        DocumentService.addDocument filename, file, title
        @categories = Tag.all
        view_noti
        @succes = 'Documento cargado correctamente'
        return erb :add_doc, layout: :layout_main 
      rescue ArgumentError => e
        return erb :add_doc, :locals => {:errorMessage => e.message}, layout: :layout_sig
      rescue ValidationModelError => e
        return erb :add_doc, :locals => e.errors, layout: :layout_sig
      end
    end
  end


  def view_noti
    if @current_user
      id = Labelled.select(:document_id).where(readed: 'f', user_id: @current_user.id)
      @noti = Document.where(delete: 'f', id: id).count
    end
  end
end
