require 'sinatra/base'
require './services/userService'
require './exceptions/ValidationModelError.rb'

class Account_controller < Sinatra::Base

	include FileUtils::Verbose

  configure :development, :production do
    enable :logging
    enable :sessions
    set :session_secret, 'OHWDOI"(U$!"$"!$="UEW=DJH OHWDOI"(U$!"$"!$="UEW=DJH OHWDOI"(U$!"$"!$="UEW=DJH'
    set :sessions, true
    set :server, 'thin'
    set :sockets, []
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
      userService.registerUser name, surname, email, username, password, password2
      redirect '/docs'
    rescue ArgumentError => e
       return erb :registerView, :locals => {:errorMessage => e.message}
    rescue ValidationModelError => e
      return erb :registerView, :locals => e.errors
    end
  end
end
