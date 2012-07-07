#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

module MPD; class Controller

class Commands
	class Command
		attr_reader :name

		def initialize (name, usable = true)
			@name   = name
			@usable = usable
		end

		def usable?
			@usable
		end
	end

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
		@commands   = []

		controller.do(:commands).each {|_, name|
			@commands << Command.new(name)
		}

		controller.do(:notcommands).each {|_, name|
			@commands << Command.new(name, false)
		}
	end

	def each (&block)
		return to_enum unless block_given?

		@commands.each(&block)

		self
	end

	def inspect
		"#<#{self.class.name}: #{map {|c| "#{'-' unless c.usable?}#{c.name}"}.join ' '}>"
	end
end

end; end
