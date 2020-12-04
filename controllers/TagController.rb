require 'sinatra/base'
require './services/TagService'
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

  get '/maketag' do
    @current_user = User.find(id: session[:user_id])
    @admin = @current_user.admin
    view_noti
    erb :maketags, layout: :layout_main
  end

  post '/maketag' do
    @current_user = User.find(id: session[:user_id])
    @admin = @current_user.admin
    newtag = params[:newtag]
    add = params[:add]
    deltag = params[:deltag]
    delete = params[:delete]
    view_noti
    begin
      TagService.makeTag newtag, add, deltag, delete
      return erb :maketags, layout: :layout_main
    rescue ArgumentError => e
       return erb :maketags, :locals => {:errorMessage => e.message}, layout: :layout_main
    rescue ValidationModelError => e
      return erb :maketags, :locals => e.errors, layout: :layout_main
    end
  end

  get '/tags' do
    @categories = Tag.select(:id).where(id: Subscription.select(:tag_id).where(user_id: session[:user_id]))
    @categories = Tag.where(id: @categories).all
    @errorcat = 'No esta suscripto a ninguna categoria' if @categories == []

    @tags = Tag.select(:id).except(Subscription.select(:tag_id).where(user_id: session[:user_id]))
    @tags = Tag.where(id: @tags).all
    @errortag = 'Esta suscripto a todas las categorias' if @tags == []
    @current_user = User.find(id: session[:user_id])
    @admin = @current_user.admin
    view_noti
    return erb :suscription, layout: :layout_main
  end

  post '/tags' do
    request.body.rewind
    @current_user = User.find(id: session[:user_id])
    @admin = @current_user.admin
    tags = []
    categories = Tag.all
    categories.each do |category|
      nombre = category.name
      if params[nombre]
        tags << nombre
      end
    end
    TagService.manageTag @current_user, params[:suscribe], params[:unsuscribe], params[:tag], tags
    @succes = "cambios registrados correctamente"
    @categories = Tag.select(:id).where(id: Subscription.select(:tag_id).where(user_id: session[:user_id]))
    @categories = Tag.where(id: @categories).all
    @errorcat = 'No esta suscripto a ninguna categoria' if @categories == []

    @tags = Tag.select(:id).except(Subscription.select(:tag_id).where(user_id: session[:user_id]))
    @tags = Tag.where(id: @tags).all
    @errortag = 'Esta suscripto a todas las categorias' if @tags == []
    return erb :suscription, layout: :layout_main
  end

  def view_noti
    if @current_user
      id = Labelled.select(:document_id).where(readed: 'f', user_id: @current_user.id)
      @noti = Document.where(delete: 'f', id: id).count
    end
  end
end
