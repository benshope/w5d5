require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

# Why isn't this, and searchable, included in SQL object?
# The methods here seem like methods that every SQL object should have.

module Associatable
	def belongs_to(name, params)


	end

end