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

class Commands < BasicObject
	attr_reader :controller

	def initialize (controller, &block)
		@controller = controller
		@commands   = []

		instance_exec &block if block
	end

	def method_missing (id, *args)
		@commands << ::MPD::Protocol::Command.new(id, args)
	end

	def send
		controller.puts ::MPD::Protocol::CommandList.new(@commands).to_s

		result = []

		@commands.each {|command|
			result << ::MPD::Protocol::Response.read(controller, command)

			break if result.last.is_a? ::MPD::Protocol::Error
		} and controller.readline

		result
	end
end

end; end
