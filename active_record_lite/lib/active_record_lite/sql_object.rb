
# SQL Object contains the DB methods that every object must have
# This class gets all the mass assignment features from mass assignment
# This class also gets
# This class will be inherited by a class with variables that are DB rows
# The table name is contained in this class
# Mehhod All returns objects created from the rows in the table
# Method Find(id) returns a single object from a row
# Methods Save, Update, and Create all put the attributes in the DB

require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject << MassObject
	extend Associatable
	extend Searchable


	@table_name
	def self.set_table_name(name)
		@table_name = name
	end

	def self.table_name
		@table_name
	end

	def self.all
		entire_table = DBConnection.execute(<<-SQL)
			SELECT *
			FROM #{@table_name}
		SQL

		objects(entire_table)
	end

	def self.find(id)
		row = DBConnection.execute(<<-SQL, id)
			SELCT *
			FROM #{@table_name}
			WHERE id = ?
		SQL

		objects(row)[0]
	end

	def save
		if id.nil?
			create
		else
			update
		end
	end

	def create
		item = DBConnection.execute(<<-SQL, *self.class.attributes.map { |x| self.send(x)})
			INSERT INTO #{self.class.table_name} (#{self.class.attributes.join(", ")})
			VALUES #{(self.class.attributes.length * ['? ']).join(", ")}
	  SQL

		self.id = DBConnection.last_insert_row_id
	end

	def update
		attributes_string = self.class.attributes.map { |x| "#{x}= ?" }.join(", ")

		item = DBConnection.execute(<<-SQL, *self.class.attributes.map { |x| self.send(x) }, id)
		UPDATE #{self.class.table_name}
		SET #{attributes_string}
		WHERE id = ?
		SQL
	end

end