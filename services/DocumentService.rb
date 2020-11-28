require './exceptions/ValidationModelError.rb'
require 'sinatra/base'
require 'date'
require 'tempfile'
require 'sinatra'
require './models/user.rb'
require 'sinatra-websocket'

class DocumentService

	def self.addDocument(filename, file, title, labelleds, tags)
		if filename.empty? or title.empty? 
      raise ArgumentError.new("Complete todos los campos")
    end
    File.open("./public/file/#{filename}", 'wb') do |f|
        f.write(file.read)
      end
    time = Time.now.to_i
    name = "#{time}#{title}".gsub(' ', '')

    src = "file/#{name}.pdf"

    doc = Document.new(title: title, 
                       date: Date.today, 
                       location: src,
                       delete: 'f')

    unless doc.valid?
      raise ValidationModelError.new("Datos para crear el documento incorrectos", doc.errors)
    end
    doc.save
    FileUtils.cp(file.path, "public/#{src}")

    users_involved = []
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
      next unless tags.include? nombre

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
      return users_involved
    end
	end