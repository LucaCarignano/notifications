# frozen_string_literal: true

<<<<<<< HEAD
=======
# Labelled class
>>>>>>> correccion_manual_de_errores
class Labelled < Sequel::Model(:documents_users)
  many_to_one :users
  many_to_one :documents
end
