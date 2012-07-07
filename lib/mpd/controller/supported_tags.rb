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

class SupportedTags
	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
		@supported  = []

		controller.do(:tagtypes).each {|_, name|
			@supported << name.to_sym
		}
	end

	def each (&block)
		@supported.each(&block)
	end
end

end; end