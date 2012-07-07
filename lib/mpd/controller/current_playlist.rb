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
		raise_if_error controller.do(:addid, uri, *position).first.last
	end

	def delete (what)
		if what.is_a?(Integer) || what.is_a?(Range)
			raise_if_error controller.do :delete, what
		else
			raise_if_error controller.do :deleteid, what
		end

		self
	end

	def move (from, to)
		if from.is_a?(Integer) || what.is_a?(Range)
			raise_if_error controller.do :move, from, to
		else
			raise_if_error controller.do :moveid, from, to
		end

		self
	end

	def clear
		raise_if_error controller.do :clear
	end

	def save_as (name)
		raise_if_error controller.do :save, name
	end

	def search (pattern, options = { tag: :title, strict: false })
		Database::Song.from_data(raise_if_error controller.do(options[:strict] ? :playlistfind : :playlistsearch, options[:tag], pattern))
	end

	def each
		return to_enum unless block_given?

		Database::Song.from_data(controller.do(:playlistinfo)).each {|song|
			yield song
		}

		self
	end

	def [] (id)
		Database::Song.from_data(controller.do(:playlistid, id))
	end

	def priority (priority, *args)
		raise_if_error controller.do :prio, priority, *args.select { |o| o.is_a?(Range) }
		raise_if_error controller.do :prioid, priority, *args.reject { |o| o.is_a?(Range) }

		self
	end

	def shuffle (range = nil)
		raise_if_error controller.do :shuffle, *range

		self
	end

	def swap (a, b)
		if a.is_a?(Integer) && b.is_a?(Integer)
			raise_if_error controller.do :swap, a, b
		else
			raise_if_error controller.do :swapip, a, b
		end

		self
	end
end

end; end
