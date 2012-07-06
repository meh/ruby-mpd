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
			controller.do :play, what[:position]
		elsif what[:id]
			controller.do :playid, what[:id]
		else
			controller.do :play, what.to_sym
		end

		self
	end

	def pause
		controller.do :pause, true

		self
	end

	def unpause
		controller.do :pause, false

		self
	end

	def stop
		controller.do :stop

		self
	end

	def next
		controller.do :next

		self
	end

	def prev
		controller.do :previous

		self
	end

	def volume (volume)
		controller.do :setvol, volume

		self
	end

	def crossfade (seconds)
		controller.do :crossfade, seconds

		self
	end

	def mixer (options)
		if options[:decibels]
			controller.do :mixrampdb, options[:decibels]
		end

		if options[:delay]
			controller.do :mixrampdelay, options[:delay]
		end

		self
	end

	def replay_gain (mode = nil)
		if mode
			controller.do :replay_gain_mode, mode

			self
		else
			controller.do(:replay_gain_status).first.last
		end
	end

	def seek (second, optional = {})
		if optional[:position]
			controller.do :seek, optional[:position], second
		elsif optional[:id]
			controller.do :seekid, optional[:id], second
		else
			controller.do :seekcur, second
		end

		self
	end
end

end; end
