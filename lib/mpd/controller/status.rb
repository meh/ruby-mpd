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

class Status
	Mixer          = Struct.new(:decibels, :delay)
	Playlist       = Struct.new(:version, :length, :current, :next)
	Playlist::Song = Struct.new(:position, :id, :elapsed)

	attr_reader :controller, :song, :mixer, :volume, :crossfade, :playlist, :bitrate, :error

	def initialize (controller)
		@controller = controller

		@mixer    = Mixer.new
		@playlist = Playlist.new

		controller.do_and_raise_if_needed(:status).each {|name, value|
			case name
			when :state          then @status           = value
			when :repeat         then @repeat           = value
			when :random         then @random           = value
			when :single         then @single           = value
			when :consume        then @consume          = value
			when :volume         then @volume           = value
			when :xfade          then @crossfade        = value
			when :mixrampdb      then @mixer.decibels   = value
			when :mixrampdelay   then @mixer.delay      = value
			when :bitrate        then @bitrate          = value
			when :error          then @error            = value
			when :playlist       then @playlist.version = value
			when :playlistlength then @playlist.length  = value

			when :song    then (@playlist.current ||= Playlist::Song.new).position = value
			when :songid  then (@playlist.current ||= Playlist::Song.new).id       = value
			when :time    then (@playlist.current ||= Playlist::Song.new).elapsed  = value
			when :elapsed then (@playlist.current ||= Playlist::Song.new).elapsed  = value

			when :nextsong   then (@playlist.next ||= Playlist::Song.new).position = value
			when :nextsongid then (@playlist.next ||= Playlist::Song.new).id       = value
			end
		}

		@song = Database::Song.from_data(controller.do_and_raise_if_needed(:currentsong))

		if playlist.current
			@song.position = playlist.current.elapsed
		end
	end

	def repeat?;  @repeat; end
	def random?;  @random; end
	def single?;  @single; end
	def consume?; @consume; end

	def == (other)
		super || to_sym.downcase == other.to_sym.downcase
	end

	def to_sym
		@status
	end
end

end; end
