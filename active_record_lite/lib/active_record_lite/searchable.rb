

# I have no idea why this is in it's own module.
# Shouldn't every SQL object be searchable?
# Is searchable useful somewhere else?
# If it is needed in associable, wouldn't it already be available?

require_relative './db_connection'

module Searchable
	def where(params)
		qmark_string = params.map { |name, value| "#{name}=?"}.join(", ")

		rows = DBConnection.execute(<<-SQL, *params.values)
			SELECT *
			FROM #{table_name}
			WHERE #{qmark_string}
		SQL

		objects(rows)
	end
end