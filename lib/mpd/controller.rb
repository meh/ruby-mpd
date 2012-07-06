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

require 'mpd/controller/do'
require 'mpd/controller/stats'
require 'mpd/controller/config'
require 'mpd/controller/supported_tags'
require 'mpd/controller/supported_protocols'
require 'mpd/controller/commands'
require 'mpd/controller/decoders'
require 'mpd/controller/audio'
require 'mpd/controller/toggle'
require 'mpd/controller/player'
require 'mpd/controller/status'
require 'mpd/controller/channels'

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

	def do (*args, &block)
		if block
			Do.new(self, &block).send
		else
			name    = args.shift
			command = Protocol::Command.new(name, args)

			@socket.puts command.to_s

			Protocol::Response.read(self, command)
		end
	end

	def authenticate (password)
		self.do :password, password

		self
	end

	def active?
		self.do(:ping).success?
	rescue
		false
	end

	def kill!
		self.do :kill
	end

	def disconnect!
		self.do :close
	end

	def stats
		Stats.new(self)
	end

	def audio
		@audio ||= Audio.new(self)
	end

	def config
		Config.new(self)
	end

	def supported_tags
		SupportedTags.new(self)
	end

	def supported_protocols
		SupportedProtocols.new(self)
	end

	def commands
		Commands.new(self)
	end

	def decoders
		Decoders.new(self)
	end

	def toggle
		@toggle ||= Toggle.new(self)
	end

	def player
		@player ||= Player.new(self)
	end

	def playlist
		@playlist ||= Playlist.new(self)
	end

	def status
		Status.new(self)
	end

	def channels
		@channels ||= Channels.new(self)
	end

	def channel (name)
		channels[name]
	end

	def wait
		self.do(:idle).map(&:last)
	rescue Interrupt
		stop_waiting and raise # my undead army
	end

	def wait_for (*args)
		self.do(:idle, *args.flatten.compact.uniq).map(&:last)
	rescue Interrupt
		stop_waiting and raise # my undead army
	end

	def stop_waiting
		self.do :noidle
	end
end

end
