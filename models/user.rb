class User < Sequel::Model
	plugin :validation_helpers
	def validate
		super
		validates_presence [:surname, :email, :password, :username]
		validates_unique [:email, :username]	
	end
end