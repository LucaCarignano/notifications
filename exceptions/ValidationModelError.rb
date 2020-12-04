class ValidationModelError < StandardError
	attr_reader :errors
	
	def initialize(msg = "Los datos ingresados no son correctos", errors)
		super(msg)
		@errors = errors
	end
end
