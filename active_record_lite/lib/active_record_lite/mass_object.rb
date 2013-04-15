
# Mass Object is a blank object, the base for the Model class
# MassObject places key/values into variables/values

class MassObject
	@attributes = []
	# Why do we set the attributes first?
	# I am guessing this limits a user's ability to toss arbitrary chunks of data into the model
	# Tons of data getting assigned to the model, in weird ways, could screw with the database after a save happens

	def self.set_attrs(*attributes)
		@attributes = attributes
		attributes.each do |attribute|
			attr_accessor attribute
		end
	end

	def self.attributes
	  @attributes
	end

	def initialize(params = {})
		params.each do |key, value|
			if self.class.attributes.include?(key)
				# Why can't we just call the method with the value?  Why use send?
				# By the time this is being called, shouldn't all the methods have been created already?
				# I am guessing this has to do with inheritance.  Perhaps self.method refers to a class object
				# Perhaps self.send refers to the instantiated model object
				# Most likely, send is just the best way to call a method, when all you have is a string
				self.send("#{key.to_sym}=", value)
			else
				raise "Bad assignment to #{key}"
			end
		end
	end
	# Why is this located here?  Like, I know what it does, converts an array of attributes into a bunch of objects.
	# But still, why do this here?  Wouldn't this work just as well in the SQL class?
	# Perhaps the reasoning is that the SQL class is already kind-of long, and this leads into mass assignment
	def self.objects(rows)
	    rows.map { |row| self.new(row) }
	end
end