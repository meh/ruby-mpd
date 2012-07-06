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

class Song
	def self.from_data (data, controller = nil)
		if data.count { |name, _| name == :file } > 1
			result  = []
			to_read = nil

			data.each {|name, value|
				if name == :file
					if to_read
						result << Song.from_data(to_read, controller)
					end

					to_read = [[name, value]]
				else
					to_read << value
				end
			}

			result
		else
			song = new(controller)

			data.each {|name, value|
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

			song
		end
	end

	attr_reader   :controller, :tags
	attr_accessor :file, :position, :duration

	def initialize (controller)
		@controller = controller
		@tags       = OpenStruct.new
	end

	def add
		raise unless controller
	end

	%w[track title artist album genre].each {|name|
		define_method name do
			tags.__send__ name
		end
	}
end

end; end
