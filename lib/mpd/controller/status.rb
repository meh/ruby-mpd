#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'ostruct'

module MPD; class Controller

class Status
	class Song
		attr_reader   :controller, :tags
		attr_accessor :file, :position, :duration

		def initialize (controller)
			@controller = controller
			@tags       = OpenStruct.new
		end

		%w[track title artist album genre].each {|name|
			define_method name do
				tags.__send__ name
			end
		}
	end

	class Mixer
		attr_reader   :controller
		attr_accessor :decibels, :delay

		def initialize (controller)
			@controller = controller
		end
	end

	attr_reader :controller, :song, :mixer, :volume, :crossfade

	def initialize (controller)
		@controller = controller

		@song  = Song.new(controller)
		@mixer = Mixer.new(controller)

		controller.do(:status).each {|name, value|
			case name
			when :state        then @status         = value
			when :volume       then @volume         = value
			when :xfade        then @crossfade      = value
			when :mixrampdb    then @mixer.decibles = value
			when :mixrampdelay then @mixer.delay    = value
			end
		}

		controller.do(:currentsong).each {|name, value|
			case name
			when :file   then song.file        = value
			when :Pos    then song.position    = value
			when :Time   then song.duration    = value
			when :Track  then song.tags.track  = value
			when :Title  then song.tags.title  = value
			when :Artist then song.tags.artist = value
			when :Album  then song.tags.album  = value
			when :Genre  then song.tags.genre  = value
			end
		}
	end

	def == (other)
		super || to_sym.downcase == other.to_sym.downcase
	end

	def to_sym
		@status
	end
end

end; end
