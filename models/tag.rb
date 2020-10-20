# frozen_string_literal: true

<<<<<<< HEAD
=======
# Tag class
>>>>>>> correccion_manual_de_errores
class Tag < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:name]
    validates_unique [:name]
  end
  many_to_many :users
  many_to_many :documents
end
