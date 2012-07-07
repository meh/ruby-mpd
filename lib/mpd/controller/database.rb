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

class Database
	class Song
		Tags = Struct.new(:track, :title, :artist, :album, :genre, :date, :composer, :performer, :disc, :id)

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
					when :file                then song.file           = value
					when :Pos                 then song.position       = value
					when :Time                then song.duration       = value
					when :Track               then song.tags.track     = value
					when :Title               then song.tags.title     = value
					when :Artist              then song.tags.artist    = value
					when :Album               then song.tags.album     = value
					when :Genre               then song.tags.genre     = value
					when :Date                then song.tags.date      = value
					when :Composer            then song.tags.composer  = value
					when :Performer           then song.tags.performer = value
					when :Disc                then song.tags.disc      = value
					when :MUSICBRAINZ_TRACKID then song.tags.id        = value
					end
				}

				song
			end
		end

		attr_reader   :controller, :tags
		attr_accessor :file, :position, :duration

		def initialize (controller)
			@controller = controller
			@tags       = Tags.new
		end

		def add
			raise unless controller
		end

		def respond_to_missing (id, include_private = false)
			@tags.respond_to?(id, include_private)
		end

		def method_missing (id, *)
			if @tags.respond_to? id
				return @tags.__send__ id
			end

			super
		end
	end

	class Directory
		include Enumerable

		attr_reader :database

		def initialize (database)
			@database = database
		end
	end

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def select (pattern, options = { tag: :title, strict: false })
		Song.from_data(controller.do(options[:strict] ? :find : :search, options[:tag], pattern))
	end

	def each

	end

	def update (*args)
		options = args.last.is_a?(Hash) ? args.pop : { force: false }
		uri     = args.shift

		if options[:force]
			controller.do :rescan, *uri
		else
			controller.do :update, *uri
		end

		self
	end
end

end; end
