#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'stringio'

require 'mpd/protocol/response'
require 'mpd/protocol/command'
require 'mpd/protocol/command_list'

module MPD
	def self.raise_if_error (response)
		if response.is_a?(Protocol::Error)
			raise response.message
		end

		response
	end
end
