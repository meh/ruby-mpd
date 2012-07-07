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

class Stats
	Database = Struct.new(:playtime, :update)

	attr_reader :controller, :artists, :songs, :uptime, :playtime, :database

	def initialize (controller)
		@controller = controller

		response = controller.do(:stats).to_hash

		@artists  = response[:artists]
		@songs    = response[:songs]
		@uptime   = response[:uptime]
		@playtime = response[:playtime]
		@database = Database.new(response[:db_playtime], response[:db_update])
	end
end

end; end
