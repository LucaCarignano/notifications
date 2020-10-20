# frozen_string_literal: true

<<<<<<< HEAD
=======
# Subscription class
>>>>>>> correccion_manual_de_errores
class Subscription < Sequel::Model(:tags_users)
  many_to_one :users
  many_to_one :tags
end
