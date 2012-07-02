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

	def each_name
		controller.command(:channels).each {|_, name|
			yield name
		}
	end

	def each
		each_name {|name|
			yield self[name]
		}
	end

	def [] (name)
		@channels << WeakRef.new(Channel.new(self, name))
	end

	def subscribed? (name)
		each_name.include?(name)
	end

	def subscribe (name)
		controller.command :subscribe, name
	end

	def unsubscribe (name)
		controller.command :unsubscribe, name
	end

	def send_message (name, text)
		controller.command :sendmessage, name, text
	end

private
	def read_messages (wait = false)
		response = controller.command(:readmessages)

		if response.empty?
			if wait
				controller.wait_for :message
			else
				return false
			end
		end

		@channels.select!(&:weakref_alive?)

		response.each_slice(2) {|(_, name), (_, message)|
			@channels.each {|channel|
				next unless channel.name == name

				channel.incoming(message)
			}
		}

		true
	end
end

end; end
