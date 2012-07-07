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

class Audio
	class Output
		attr_reader :audio, :id

		def initialize (audio, id)
			@audio = audio
			@id    = id
		end

		def name
			audio.controller.do(:outputs).each_slice(3) {|(_, id), (_, name), (_, enabled)|
				return name if @id == id
			}
		end

		def enabled?
			audio.controller.do(:outputs).each_slice(3) {|(_, id), (_, name), (_, enabled)|
				return enabled if @id == id
			}
		end

		def enable!
			audio.controller.do :enableoutput, id

			self
		end

		def disable!
			audio.controller.do :disableoutput, id

			self
		end

		def inspect
			"#<#{self.class.name}(#{id}, #{enabled? ? 'enabled' : 'disabled'}): #{name}>"
		end
	end

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def each
		return to_enum unless block_given?

		controller.do(:outputs).each_slice(3) {|(_, id), (_, name), (_, enabled)|
			yield Output.new(self, id)
		}

		self
	end

	def [] (matches)
		controller.do(:outputs).each_slice(3) {|(_, id), (_, name), (_, enabled)|
			return Output.new(self, id) if matches == id || matches == name
		}

		nil
	end
end

end; end
