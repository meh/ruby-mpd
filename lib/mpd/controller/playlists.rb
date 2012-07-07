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

class Playlists
	class Playlist
		include Enumerable

		attr_reader :playlists, :name, :last_modified

		def initialize (playlists, name, last_modified = nil)
			@playlists     = playlists
			@name          = name
			@last_modified = last_modified
		end

		def each
			return to_enum unless block_given?

			Database::Song.from_data(playlists.controller.do_and_raise_if_needed(:listplaylistinfo, name)).each {|song|
				yield song
			}

			self
		end

		def load (range = nil)
			playlists.controller.do_and_raise_if_needed :load, name, *range

			self
		end

		def rename (new)
			playlists.controller.do_and_raise_if_needed :rename, name, new

			self
		end

		def delete!
			playlists.controller.do_and_raise_if_needed :rm, name

			self
		end

		def add (uri)
			playlists.controller.do_and_raise_if_needed :playlistadd, name, uri
		end

		def move (from, to)
			playlists.controller.do_and_raise_if_needed :playlistmove, name, from, to

			self
		end

		def clear
			playlists.controller.do_and_raise_if_needed :playlistclear, name

			self
		end
	end

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def [] (name)
		find { |p| p.name == name.to_s }
	end

	def each
		name          = nil
		last_modified = nil

		controller.do_and_raise_if_needed(:listplaylists).each {|key, value|
			if key == :playlist
				if last_modified
					yield Playlist.new(self, name, last_modified)
				end

				name          = value
				last_modified = nil
			elsif key == :"Last-Modified"
				last_modified = value
			end
		}

		if name
			yield Playlist.new(self, name, last_modified)
		end

		self
	end
end

end; end
