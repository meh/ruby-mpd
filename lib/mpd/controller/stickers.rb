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

class Stickers
	class Sticker
		attr_reader :element, :name

		def initialize (element, name)
			@element = element
			@name    = name
		end

		def value
			response    = @element.stickers.controller.do_and_raise_if_needed(:sticker, :get, element.type, element.uri, name)
			name, value = response.first.last.split '=', 2

			value
		end

		def value= (value)
			@element.stickers.controller.do_and_raise_if_needed(:sticker, :set, element.type, element.uri, name, value)
		end

		def delete!
			@element.stickers.controller.do_and_raise_if_needed(:sticker, :delete, element.type, element.uri, name)
		end

		def inspect
			"#<#{self.class.name}(#{name}): #{value.inspect}>"
		end
	end

	class Element
		include Enumerable

		attr_reader :stickers, :type, :uri

		def initialize (stickers, type, uri)
			@stickers = stickers
			@type     = type
			@uri      = uri
		end

		def [] (name)
			find { |s| s.name == name.to_s }
		end

		def delete (name)
			self[name].delete!
		end

		def each
			return to_enum unless block_given?

			@stickers.controller.do_and_raise_if_needed(:sticker, :list, type, uri).each {|_, sticker|
				name, value = sticker.split '=', 2

				yield Sticker.new(self, name)
			}

			self
		end
	end

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def [] (uri, type = :song)
		Element.new(self, type, uri)
	end
end

end; end
