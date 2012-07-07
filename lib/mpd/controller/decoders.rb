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

class Decoders
	Decoder = Struct.new(:name, :suffixes, :mime_types)

	include Enumerable

	attr_reader :controller

	def initialize (controller)
		@controller = controller
		@decoders   = []

		name       = nil
		suffixes   = nil
		mime_types = nil

		controller.do_and_raise_if_needed(:decoders).each {|type, value|
			if type == :plugin
				if name
					@decoders << Decoder.new(name, suffixes, mime_types)
				end

				name       = value
				suffixes   = []
				mime_types = []
			elsif type == :suffix
				suffixes << value
			elsif type == :mime_type
				mime_types << value
			end
		}
	end

	def each (&block)
		return to_enum unless block_given?

		@decoders.each(&block)

		self
	end
end

end; end
