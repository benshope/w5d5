
# Why this is in a separate module?
# Shouldn't every SQLObject be searchable?
# Is the searchable module useful somewhere else?
# If it was needed in associatable, wouldn't it already be available?

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