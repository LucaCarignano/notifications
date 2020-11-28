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

  get '/docs' do
    @current_user = User.find(id: session[:user_id])
    @admin = @current_user.admin
    set_pages
    cant_pages(Document.where(delete: 'f').count)
    @documents = Document.order(:date).reverse.where(delete: 'f').limit(@docsperpage, (@page - 1) * @docsperpage)
    @categories = Tag.all
    @users = User.all
    view_noti
    erb :docs, layout: :layout_main
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

  post '/docs' do
    set_pages
    redirect '/docs' if not_filter?
    users_filter = params[:users]
    tags_filter = params[:tags]
    date_filter = params[:datedoc]
    name_filter = params[:docname]
    bot_filter = params[:filter]
    del_doc = []
    documents = Document.all
      documents.each do |doc|
        location = 'del' + doc.location
        if params[location]
          del_doc = doc 
        end
      end
    @documents = DocumentService.filterDoc users_filter, tags_filter, date_filter, name_filter, bot_filter, del_doc
    @categories = Tag.all
    @users = User.all
    view_noti
    set_pages
    cant_pages(@documents.length)
    @documents = @documents[((@page - 1) * @docsperpage)..(@page * @docsperpage) - 1]
    @current_user = User.find(id: session[:user_id])
    view_noti
    @admin = @current_user.admin
    return erb :docs, layout: :layout_main
  end

  def not_filter?
    params[:datedoc] == '' && params[:tags] == '' && params[:users] == '' && params[:filter] && params[:docname]
  end

  def set_pages
    @page = if params[:page]
              params[:page].to_i
            else 1
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

  def doc_tags(docs_tags)
    tags = []
    docs_tags.each { |tag| tags << tag.name }
    tags * ', '
  end

  def doc_users(docs_users)
    users = []
    docs_users.each { |user| users << user.username }
    users * ', '
  end

  def view_noti
    if @current_user
      id = Labelled.select(:document_id).where(readed: 'f', user_id: @current_user.id)
      @noti = Document.where(delete: 'f', id: id).count
    end
  end
end
