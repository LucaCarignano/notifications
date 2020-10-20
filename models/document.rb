# frozen_string_literal: true

<<<<<<< HEAD
=======
# Document class
>>>>>>> correccion_manual_de_errores
class Document < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[title date]
  end
  many_to_many :users
  many_to_many :tags
end
