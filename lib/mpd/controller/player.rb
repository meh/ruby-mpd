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

class Player
	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def play (what = nil)
		if what.nil?
			unpause
		elsif what.is_a? Integer
			controller.command :play, what
		else
			controller.command :play, what.to_sym
		end

		self
	end

	def pause
		controller.command :pause, true

		self
	end

	def unpause
		controller.command :pause, false

		self
	end

	def stop
		controller.command :stop

		self
	end

	def next
		controller.command :next

		self
	end

	def prev
		controller.command :previous

		self
	end

	def volume (volume)
		controller.command :setvol, volume

		self
	end

	def seek (second)
		controller.command :seekcur, second

		self
	end
end

end; end
