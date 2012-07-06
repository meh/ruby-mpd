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

class Toggle
	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def toggle (name)
		controller.do(name, !on?(name))
	end

	def on (name)
		unless on? name
			controller.do(name, true)
		end

		self
	end

	def off (name)
		if on? name
			controller.do(name, false)
		end

		self
	end

	def on? (name)
		result = controller.do(:status).to_hash[name.to_sym]

		return false if result != true && result != false

		return result
	end

	%w[pause random consume repeat single].each {|name|
		define_method name do
			toggle name
		end

		define_method "#{name}!" do
			on name
		end

		define_method "no_#{name}!" do
			off name
		end

		define_method "#{name}?" do
			on? name
		end
	}

	alias shuffle     random
	alias shuffle!    random!
	alias no_shuffle! no_random!
	alias shuffle?    random?
end

end; end
