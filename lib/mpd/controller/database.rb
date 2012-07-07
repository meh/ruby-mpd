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
						to_read << [name, value]
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

		def self.from_uri (uri, controller = nil)
			if controller
				from_data(controller.do(:listallinfo, uri), controller)
			else
				Song.new.tap {|song|
					song.file = uri
				}
			end
		end

		attr_reader   :controller, :tags
		attr_accessor :file, :position, :duration

		def initialize (controller = nil)
			@controller = controller
			@tags       = Tags.new
		end

		def add
			raise 'no controller, cannot add to playlist' unless controller
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

		alias uri file

		def inspect
			"#<#{self.class.name}: #{file.inspect}>"
		end
	end

	class Directory
		include Enumerable

		attr_reader :database, :uri

		def initialize (database, uri = nil)
			@database = database
			@uri      = uri
		end

		def each
			return enum_for :each unless block_given?

			database.controller.do(:lsinfo, *uri).each {|name, value|
				case name
				when :file      then yield Song.from_uri(value, database.controller)
				when :directory then yield Directory.new(database, value)
				end
			}

			self
		end

		def [] (name)
			each { |n| return n if n.uri == name }

			nil
		end

		def inspect
			"#<#{self.class.name}: #{uri.inspect}>"
		end
	end

	class Artist
		attr_reader :database, :name

		def initialize (database, name)
			@database = database
			@name     = name
		end

		def nil?
			name.empty?
		end

		def songs (strict = false)
			database.search(name, tag: :artist, strict: strict)
		end

		def inspect
			"#<#{self.class.name}: #{name.inspect}>"
		end
	end

	class Element
		attr_reader :database, :tag, :name

		def initialize (database, tag, name)
			@database = database
			@tag      = tag
			@name     = name
		end

		def nil?
			name.empty?
		end

		def songs (strict = false)
			database.search(name, tag: tag, strict: strict)
		end

		def inspect
			"#<#{self.class.name.sub(/::Element$/, "::#{tag.capitalize}")}: #{name.inspect}>"
		end
	end

	include Enumerable

	attr_reader :controller, :root

	def initialize (controller)
		@controller = controller
		@root       = Directory.new(self)
	end

	def tags (name, artist = nil)
		return enum_for :tags, name, artist unless block_given?

		controller.do(:list, name, *artist).each {|_, value|
			yield value
		}
	end

	%w[artists albums genres composers performers].each {|name|
		tag = name[0 .. -2].to_sym

		define_method name do |artist = nil|
			tags(tag, artist).map { |n| Element.new(self, tag, n) }
		end
	}

	def search (pattern, options = { tag: :title, strict: false })
		Song.from_data(controller.do(options[:strict] ? :find : :search, options[:tag], pattern))
	end

	def each (&block)
		return to_enum unless block_given?

		@root.each(&block)

		self
	end

	def [] (name)
		@root[name]
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
