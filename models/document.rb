# frozen_string_literal: true

# Document class
class Document < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence :title, message: "Debe indicarnos el nombre del documento"
    validates_presence :date, message: "El documento no tiene fecha de carga"
    validates_presence :location, message: "No se le cargo la ubicacion al documento"
    validates_unique :location, message: "ubicacion del documento no unica"
  end
  many_to_many :users
  many_to_many :tags
end
