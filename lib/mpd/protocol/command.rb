#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

module MPD; module Protocol

class Command
	attr_reader :name, :arguments

	def initialize (name, *arguments)
		@name      = name.to_sym
		@arguments = arguments.flatten.compact
	end

	def to_s
		result = name.to_s

		unless arguments.empty?
			result << ' ' << arguments.map {|argument|
				if argument.is_a? Range
					if argument.end == -1
						"#{argument.begin}:"
					else
						"#{argument.begin}:#{argument.end + (argument.exclude_end? ? 0 : 1)}"
					end
				elsif argument == true || argument == false
					argument ? '1' : '0'
				else
					argument = argument.to_s

					if argument.include?(' ') || argument.include?('"')
						%{"#{argument.gsub '"', '\"'}"}
					else
						argument
					end
				end
			}.join(' ')
		end

		result
	end
end

end; end
