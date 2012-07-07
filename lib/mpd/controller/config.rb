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

class Config < Hash
	attr_reader :controller

	def initialize (controller)
		@controller = controller

		controller.do_and_raise_if_needed(:config).each {|name, value|
			self[name] = value
		}

		freeze
	end

	def respond_to_missing? (id, include_private = false)
		include? id
	end

	def method_missing (id, *)
		self[id]
	end
end

end; end
