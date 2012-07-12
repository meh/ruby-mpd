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

module MPD

# This is the main class to manage moc.
#
# The class also acts as a Socket if needed.
class Controller
	autoload :Do, 'mpd/controller/do'
	autoload :Database, 'mpd/controller/database'
	autoload :Stats, 'mpd/controller/stats'
	autoload :Config, 'mpd/controller/config'
	autoload :SupportedTags, 'mpd/controller/supported_tags'
	autoload :SupportedProtocols, 'mpd/controller/supported_protocols'
	autoload :Commands, 'mpd/controller/commands'
	autoload :Decoders, 'mpd/controller/decoders'
	autoload :Audio, 'mpd/controller/audio'
	autoload :Toggle, 'mpd/controller/toggle'
	autoload :Player, 'mpd/controller/player'
	autoload :CurrentPlaylist, 'mpd/controller/current_playlist'
	autoload :Playlists, 'mpd/controller/playlists.rb'
	autoload :Status, 'mpd/controller/status'
	autoload :Channels, 'mpd/controller/channels'
	autoload :Stickers, 'mpd/controller/stickers'

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

	def do_and_raise_if_needed (*args)
		response = self.do *args

		if response.is_a?(Protocol::Error)
			raise response.message
		end

		response
	end

	def authenticate (password)
		self.do :password, password

		self
	end

	def active?
		self.do(:ping).success?
	rescue Exception
		false
	end

	def kill!
		self.do :kill
	end

	def disconnect!
		self.do :close
	end

	def database
		@database ||= Database.new(self)
	end

	def stats
		Stats.new(self)
	end

	def audio
		Audio.new(self)
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

	def playlists
		@playlists ||= Playlists.new(self)
	end

	def playlist (name = nil)
		if name
			playlists[name]
		else
			@playlist ||= CurrentPlaylist.new(self)
		end
	end

	def status
		Status.new(self)
	end

	def channels
		@channels ||= Channels.new(self)
	end

	def stickers
		@stickers ||= Stickers.new(self)
	end

	def channel (name)
		channels[name]
	end

	def idle?; !!@idle; end

	def wait (*args)
		@idle  = true
		active = self.do(:idle, *args.flatten.compact.uniq).map(&:last)

		active.empty? ? nil : active
	rescue Exception
		stop_waiting and raise # my undead army
	ensure
		@idle = false
	end

	alias wait_for wait

	def stop_waiting
		self.do(:noidle) if idle?
	end

	def loop (*what)
		while true
			(wait_for(*what) || [:break]).each {|name|
				yield name
			}
		end
	end
end

end
