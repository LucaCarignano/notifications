# frozen_string_literal: true

<<<<<<< HEAD
=======
# Category class
>>>>>>> correccion_manual_de_errores
class Category < Sequel::Model(:documents_tags)
  many_to_one :documents
  many_to_one :tags
end
