class Goofy
	def do_some_stuff(syms)
		syms.each do |sym|
			self.send(sym)
		end
	end

	def self.make_goofy_say_something(array)
		define_method(array[0]) { puts array[1] }
	end

  private
  def say_hello
    puts 'Huh huh, hey evaray-body!'
  end
end


#g.do_some_stuff([:say_hello])
Goofy.make_goofy_say_something([:say_goodbye, "Bye!"])
g = Goofy.new
g.say_goodbye