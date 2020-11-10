# frozen_string_literal: true

# User class
class User < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence :name, message: "Debe indicarnos su numbre"
    validates_presence :surname, message: "Debe indicarnos su apellido"
    validates_presence :email, message: "Debe indicarnos su email"
    validates_presence :password, message: "Debe ingresar una contraseña"
    validates_presence :username, message: "Debe ingresar un nombre de usario"
    validates_unique :email, message: "ya existe un usuario registrado con ese email"
    validates_unique :username, message: "ya existe un usuario registrado con ese nombre de usuario"
    validates_format (/ \A.*@.*\..*\z/), :email, message: 'invalid email'
    validates_min_length 6, :password, message: 'password must have more than 5 caracters'
  end
  many_to_many :tags
  many_to_many :documents
end
