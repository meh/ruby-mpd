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

class CurrentPlaylist
	class Song < Database::Song
		attr_reader :playlist, :id

		def initialize (playlist, id)
			super(playlist.controller)

			@playlist = playlist
			@id       = id

			Database::Song.from_data(playlist.controller.do_and_raise_if_needed(:playlistid, id)).tap {|song|
				@tags     = song.tags
				@file     = song.file
				@duration = song.duration
			}
		end

		def delete!
			controller.do_and_raise_if_needed :deleteid, id
		end

		def move (to)
			controller.do_and_raise_if_needed :moveid, id, to

			true
		rescue
			false
		end

		def priority (value)
			controller.do_and_raise_if_needed :prioid, value, id

			self
		end

		def swap (other)
			controller.do_and_raise_if_needed :swapip, id, b

			other
		end
	end

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def version
		controller.status.playlist.version
	end

	def length
		controller.status.playlist.length
	end

	def add (uri, position = nil)
		Song.new(self, controller.do_and_raise_if_needed(:addid, uri, *position).to_hash[:Id])
	end

	def delete (what)
		controller.do_and_raise_if_needed :delete, what

		self
	end

	def move (from, to)
		controller.do_and_raise_if_needed :move, from, to

		self
	end

	def clear
		controller.do_and_raise_if_needed :clear
	end

	def save_as (name, force = false)
		if force
			controller.playlists[name].delete!
		end

		controller.do_and_raise_if_needed :save, name

		self
	end

	def search (pattern, options = { tag: :title, strict: false })
		Database::Song.from_data(controller.do_and_raise_if_needed(options[:strict] ? :playlistfind : :playlistsearch, options[:tag], pattern))
	end

	def each
		return to_enum unless block_given?

		controller.do(:playlistid).select { |name, value| name == :Id }.each {|name, value|
			yield Song.new(self, value)
		}

		self
	end

  def songs
    controller.do(:playlistid).select { |name, value| name == :Id }.collect{ |k, v|
      Song.new(self, v)
    }
  end

	def [] (id)
		Song.new(self, id)
	end

	def priority (priority, *args)
		controller.do_and_raise_if_needed :prio, priority, *args

		self
	end

	def shuffle (range = nil)
		controller.do_and_raise_if_needed :shuffle, *range

		self
	end

	def swap (a, b)
		controller.do_and_raise_if_needed :swap, a, b

		self
	end
end

end; end
