
# Mass Object is a blank object, the base for the Model class
# MassObject places key/values into variables/values

class MassObject
	@attributes = []

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
				self.send("#{key.to_sym}=", value)
			else
				raise "Bad assignment to #{key}"
			end
		end
	end

	def self.objects(rows)
	    rows.map { |row| self.new(row) }
	end
end