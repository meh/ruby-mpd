#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'socket'

require 'mpd/protocol'

require 'mpd/controller/commands'
require 'mpd/controller/toggle'
require 'mpd/controller/player'

module MPD

# This is the main class to manage moc.
#
# The class also acts as a Socket if needed.
class Controller
	attr_reader :path, :host, :port, :version

	def initialize (host = 'localhost', port = 6600)
		@socket  = File.exists?(host) ? UNIXSocket.new(host) : TCPSocket.new(host, port)
		@version = @socket.readline.chomp.split(' ', 3).last

		if unix?
			@path = host
		else
			@host = host
			@port = port
		end
	end

	def unix?
		@socket.is_a? UNIXSocket
	end

	def tcp?
		@socket.is_a? TCPSocket
	end

	def respond_to_missing? (id, include_private = false)
		@socket.respond_to? id, include_private
	end

	def method_missing (id, *args, &block)
		if @socket.respond_to? id
			return @socket.__send__ id, *args, &block
		end

		super
	end

	def commands (&block)
		Commands.new(self, &block).send
	end

	def command (name, *args)
		command = Protocol::Command.new(name, args)

		@socket.puts command.to_s

		Protocol::Response.read(self, command)
	end

	def toggle
		Toggle.new(self)
	end

	def player
		Player.new(self)
	end
end

end
