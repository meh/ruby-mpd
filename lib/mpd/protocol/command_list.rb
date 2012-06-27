#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

module MPD; module Protocol

class CommandList
	def initialize (*commands)
		@commands = commands.flatten.compact
	end

	def respond_to_missing? (id, include_private = false)
		@commands.respond_to?(id)
	end

	def method_missing (id, *args, &block)
		if @commands.respond_to? id
			return @commands.__send__ id, *args, &block
		end

		super
	end

	def to_s
		result = StringIO.new

		result.puts 'command_list_ok_begin'
		@commands.each {|command|
			result.puts command.to_s
		}
		result.print 'command_list_end'

		result.seek 0
		result.read
	end

	def to_a
		@commands
	end
end

end; end
