require 'sinatra/base'
require './services/UserService'
require './exceptions/ValidationModelError.rb'

class TagController < Sinatra::Base

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

  get '/tags' do
    @categories = Tag.select(:id).where(id: Subscription.select(:tag_id).where(user_id: session[:user_id]))
    @categories = Tag.where(id: @categories).all
    @errorcat = 'No esta suscripto a ninguna categoria' if @categories == []

    @tags = Tag.select(:id).except(Subscription.select(:tag_id).where(user_id: session[:user_id]))
    @tags = Tag.where(id: @tags).all
    @errortag = 'Esta suscripto a todas las categorias' if @tags == []
    view_noti
    erb :suscription, layout: :layout_main
  end

  post '/tags' do
    request.body.rewind
    @current_user = User.find(id: session[:user_id])
    begin 
      TagService.manageTag @current_user, params[:suscribe], params[:unsuscribe], params[:tag]
      @error = "cambios registrados correctamente"
      return erb :suscription, layout: :layout_main
    end
  end
end
