require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

# Why isn't this located in the SQLObject class?
# The methods here should be in every SQLObject.
# What do we gain by having them in a module?

module Associatable
	def belongs_to(owner, params={})
		info = BelongsToAssoc.new(owner, params)

		# Make a method in this class, to summon the object this belongs to
		define_method(owner) do
			row = DBConnection.execute(<<-SQL, self.send(info.foreign_key)
				SELECT *
				FROM #{info.other_table}
				WHERE #{info.other_table}.#{info.primary_key} = ?
			SQL
			objects(row)
		end
	end

	def has_many(belongings, params = {})
		info = HasManyAssoc.new(belongings, params)

		# Make a method in this class, to summon all the objects that this owns
		define_method(belongings) do
	      rows = DBConnection.execute(<<-SQL, self.send(info.primary_key))
	        SELECT *
	          FROM #{info.other_table}
	         WHERE #{info.other_table}.#{info.foreign_key} = ?
	      SQL
			objects(rows)
		end
	end

	def has_one_through(belonging, join, destination)
	    define_method(belonging) do
	      # Get the two sets of parameters
	      joinobj = self.class.assoc_params[join] ||= params[join]
	      destinationobj = joinobj.other_class.assoc_params[destination]
  	  	  # Build a join query from both sets of parameters
          other_key = self.send(destinationobj.foreign_key)
          rows = DBConnection.execute(<<-SQL, pk1)
          SELECT #{destinationobj.other_table}.*
            FROM #{destinationobj.other_table}
            JOIN #{joinobj.other_table}
              ON #{destinationobj.other_table}.#{joinobj.foreign_key} = #{joinobj.other_table}.#{joinobj.primary_key}
           WHERE #{destinationobj.other_table}.#{destinationobj.primary_key} = ?
          SQL

          objects(rows)[0]
	    end
	end


	class Assoc
		# Make all this stuff readable
		attr_reader :primary_key, :foreign_key, :other_class_name, :other_class, :other_table
	end

	class HasManyAssoc < Assoc
		def initialize(belongings, params)
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
		end
	end

	class BelongsToAssoc < Assoc
		def initialize(owner, params)
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
		end
	end


end