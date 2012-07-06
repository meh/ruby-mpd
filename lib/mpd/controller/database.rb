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
	attr_reader :controller

	def initialize (controller)
		@controller = controller
	end

	def select (pattern, options = { tag: :title, strict: false })
		Song.from_data(controller.do(options[:strict] ? :find : :search, options[:tag], pattern))
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
