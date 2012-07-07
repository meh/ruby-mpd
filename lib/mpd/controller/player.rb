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

	def play (what = {})
		if what[:position]
			controller.do_and_raise_if_needed :play, what[:position]
		elsif what[:id]
			controller.do_and_raise_if_needed :playid, what[:id]
		else
			controller.do_and_raise_if_needed :play, what.to_sym
		end

		self
	end

	def pause
		controller.do_and_raise_if_needed :pause, true

		self
	end

	def unpause
		controller.do_and_raise_if_needed :pause, false

		self
	end

	def stop
		controller.do_and_raise_if_needed :stop

		self
	end

	def next
		controller.do_and_raise_if_needed :next

		self
	end

	def prev
		controller.do_and_raise_if_needed :previous

		self
	end

	def volume (volume)
		controller.do_and_raise_if_needed :setvol, volume

		self
	end

	def crossfade (seconds)
		controller.do_and_raise_if_needed :crossfade, seconds

		self
	end

	def mixer (options)
		if options[:decibels]
			controller.do_and_raise_if_needed :mixrampdb, options[:decibels]
		end

		if options[:delay]
			controller.do_and_raise_if_needed :mixrampdelay, options[:delay]
		end

		self
	end

	def replay_gain (mode = nil)
		if mode
			controller.do_and_raise_if_needed :replay_gain_mode, mode

			self
		else
			controller.do_and_raise_if_needed(:replay_gain_status).first.last
		end
	end

	def seek (second, optional = {})
		if optional[:position]
			controller.do_and_raise_if_needed :seek, optional[:position], second
		elsif optional[:id]
			controller.do_and_raise_if_needed :seekid, optional[:id], second
		else
			controller.do_and_raise_if_needed :seekcur, second
		end

		self
	end
end

end; end
