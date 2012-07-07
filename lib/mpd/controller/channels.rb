#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'weakref'

module MPD; class Controller

class Channels
	class Channel
		attr_reader :name

		def initialize (channels, name)
			@channels = channels
			@name     = name
			@buffer   = []
		end

		def incoming (text)
			@buffer << text
		end

		def send_message (text)
			@channels.send_message(@name, text)
		end

		def read_message
			@channels.send :read_messages, true while @buffer.empty?
			@buffer.shift
		end

		def read_message_nonblock
			@channels.send :read_messages
			@buffer.shift
		end
	end

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
		@channels   = []
	end

	def names
		controller.do_and_raise_if_needed(:channels).map(&:last)
	end

	def each_name (&block)
		names.each(&block)
	end

	def each
		return to_enum unless block_given?

		each_name {|name|
			yield self[name]
		}

		self
	end

	def [] (name, sub = true)
		subscribe name if sub

		Channel.new(self, name).tap {|channel|
			@channels << WeakRef.new(channel)
		}
	end

	def subscribe (name)
		controller.do_and_raise_if_needed :subscribe, name
	end

	def unsubscribe (name)
		controller.do_and_raise_if_needed :unsubscribe, name
	end

	def send_message (name, text)
		controller.do_and_raise_if_needed :sendmessage, name, text
	end

private
	def read_messages (wait = false)
		response = controller.do_and_raise_if_needed :readmessages

		if response.empty?
			if wait
				controller.wait_for :message
			else
				return false
			end
		end

		response.each_slice(2) {|(_, name), (_, message)|
			@channels.each {|channel|
				next unless channel.weakref_alive? && channel.name.to_s == name.to_s

				channel.incoming(message)
			}
		}

		@channels.select!(&:weakref_alive?)

		true
	end
end

end; end
