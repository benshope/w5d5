require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

# Why isn't this located in the SQLObject class?
# The methods here should be in every SQLObject.
# What do we gain by having them in a module?

module Associatable
	def belongs_to(owner, params={})
		# Foreign key defaults to :thisclassname_id
		@foreign_key = params[:foreign_key]) || "#{owner}_id".to_sym
		# Primary key defaults to :id
		@primary_key = params[:primary_key] || :id
		# The name of the other class has been passed in
		@other_class_name = (params[:class_name] || owner.to_s.camelcase)
		# This creates an instance of the other class
		@other_class = other_class_name.constantize
		# This asks the other class for it's table name
		@other_table = other_class.table_name

		# Make a method in this class, to summon the object this belongs to
		define_method(owner) do
			row = DBConnection.execute(<<-SQL, self.send(foreign_key)
				SELECT *
				FROM #{other_table}
				WHERE #{other_table}.#{primary_key} = ?
			SQL
			objects(row)
		end
	end

	def has_many(belongings, params = {})
		# Primary key defaults to :id
		@primary_key = params[:primary_key] || :id
		# Foreign key defaults to the name of this class
		@foreign_key = (params[:foreign_key] || "#{self.name.underscore}_id".to_sym)
		# The name of the other class was passed in
		@other_class_name = (params[:class_name] || belongings.to_s.singularize.camelcase)
		# This creates an instance of the other class
		@other_class = other_class_name.constantize
		# This asks the other class for it's table name
		@other_table = other_class.table_name

		# Make a method in this class, to summon all the objects that this owns
		define_method(belongings) do
      rows = DBConnection.execute(<<-SQL, self.send(primary_key))
        SELECT *
          FROM #{other_table}
         WHERE #{other_table}.#{foreign_key} = ?
      SQL
			objects(rows)
		end
	end
end