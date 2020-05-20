class Suscription < Sequel::Model(:tags_users)
	many_to_one :users
	many_to_one :tags
end