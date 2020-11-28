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

  get '/' do
    if !request.websocket?
      erb :log, layout: :layout_sig
    else
      request.websocket do |ws|
        user = session[:user_id]
        logger.info(user)
        @connection = { user: user, socket: ws }
        ws.onopen do
          settings.sockets << @connection
        end
        ws.onclose do
          warn('websocket closed')
          settings.sockets.delete(ws)
        end
      end
    end
  end

	get '/log' do
    logger.info ''
    logger.info session['session_id']
    logger.info session.inspect
    logger.info '-------------'
    logger.info ''

    if !user_logged?
      erb :log, layout: :layout_sig
    else
      redirect '/docs'
    end
  end

  post '/log' do
    if params[:Login]
      user1 = User.find(username: params[:user])
      if user1 && user1.password == params[:pass]
        session[:user_id] = user1.id
        redirect '/docs'
      elsif !user1 || params[:user] == '' || params[:pass] == '' || user1.password != params[:pass]
        redirect '/login'
      end
    end
    # register part
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json
    name = params['name']
    surname = params['surname']
    email = params['email']
    username = params['username']
    password = params['password']
    password2 = params['password2']
   
    begin 
      UserService.registerUser name, surname, email, username, password, password2
      redirect '/docs'
    rescue ArgumentError => e
       return erb :log, :locals => {:errorMessage => e.message}, layout: :layout_sig
    rescue ValidationModelError => e
      return erb :log, :locals => e.errors, layout: :layout_sig
    end
  end

  def user_logged?
    session[:user_id]
  end

  get '/profile' do
    @current_user = User.find(id: session[:user_id])
    @username = @current_user.username
    @email = @current_user.email
    @noti = UserService.view_noti @current_user
    erb :profile, layout: :layout_main
  end

  post '/profile' do

    request.body.rewind
    @current_user = User.find(id: session[:user_id])

    botusername = params[:botuser]
    botemail = params[:botemail]
    botpass = params[:botpass]
    editusername = params[:editus]
    editemail = params[:editemail]
    editpass = params[:editpass]
    newusername = params[:newuser]
    newemail = params[:newemail]
    newpass = params[:newpass]
    repass = params[:repas]
    oldpass = params[:oldpass]

    @username = @current_user.username
    @email = @current_user.email
    if botusername 
      @edituse = 'entro'
      return erb :profile, layout: :layout_main
    elsif botemail
      @editmail = 'entro'
      return erb :profile, layout: :layout_main
    elsif botpass
      @editpas = 'entro'
      return erb :profile, layout: :layout_main
    end
      
    @noti = UserService.view_noti @current_user
    
    begin 
      UserService.modifyUser @current_user, editusername, editemail, editpass, 
                           botusername, botemail, botpass, newusername, 
                           newemail, newpass, repass, oldpass

      @username = @current_user.username
      @email = @current_user.email
      @succes = "datos actualizados correctamente"
      return erb :profile, layout: :layout_main
    rescue ArgumentError => e
       return erb :profile, :locals => {:errorMessage => e.message}, layout: :layout_main
    rescue ValidationModelError => e
      return erb :profile, :locals => e.errors, layout: :layout_main
      
    end
  end

end
