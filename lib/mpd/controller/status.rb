#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'ostruct'

module MPD; class Controller

class Status
	class Song
		attr_reader :controller, :tags

		def initialize (controller)
			@controller = controller
			@tags       = OpenStruct.new
		end
	end

	attr_reader :controller, :settings

	def initialize (controller)
		@controller = controller

		@song     = Song.new(controller)
		@settings = OpenStruct.new

		controller.command(:status).each {|name, value|
			case name
			when :state
				@status = value

			end
		}
	end

	def == (other)
		super || to_sym.downcase == other.to_sym.downcase
	end

	def to_sym
		@status
	end
end

end; end
