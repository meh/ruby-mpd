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

class Response
	class Data
		attr_reader :name, :value

		def initialize (name, value)
			@name  = name
			@value = case name
			when :artists, :albums, :songs, :uptime, :playtime, :db_playtime, :volume, :playlist, :playlistlength, :xfade
				value.to_i

			when :mixrampdb, :mixrampdelay
				value == 'nan' ? Float::NAN : value.to_f

			when :repeat, :random, :single, :consume
				value != '0'

			when :db_update
				Time.at(value.to_i)

			when :command, :state
				value.to_sym

			else value
			end
		end
	end

	def self.read (io, command)
		result = []

		while (line = io.readline) && !line.match(/^(list_)?OK(\s|$)/) && !line.start_with?('ACK ')
			name, value = line.split ': ', 2
			name        = name.to_sym
			value       = value.chomp

			result << Data.new(name, value)
		end

		type, message = line.split ' ', 2

		if type == 'OK' || type == 'list_OK'
			Ok.new(command, result, message)
		else
			Error.new(command, result, *Error.parse(message))
		end
	end

	def self.parse (text)
		read(StringIO.new(text))
	end

	include Enumerable

	attr_reader :command

	def initialize (command, data)
		@command  = command
		@internal = data.freeze
	end

	def each
		@internal.each {|data|
			yield [data.name, data.value]
		}

		self
	end

	def to_a
		@internal
	end

	def to_hash
		return @hash if @hash

		result = {}

		each {|name, value|
			if result[name]
				if result[name].is_a? Array
					result[name] << value
				else
					result[name] = [result[name], value]
				end
			else
				result[name] = value
			end
		}

		@hash = result.freeze
	end
end

class Ok < Response
	attr_reader :message

	def initialize (command, data, message)
		super(command, data)

		@message = message
	end
end

class Error < Response
	Codes = {
		NOT_LIST:   1,
		ARG:        2,
		PASSWORD:   3,
		PERMISSION: 4,
		UNKNOWN:    5,

		NO_EXIST:       50,
		PLAYLIST_MAX:   51,
		SYSTEM:         52,
		PLAYLIST_LOAD:  53,
		UPDATE_ALREADY: 54,
		PLAYER_SYNC:    55,
		EXIST:          56
	}

	def self.parse (text)
		text.match(/^\[(\d+)@(\d+)\] {([^}]*)} (.*?)$/).to_a[1 .. -1]
	end

	attr_reader :offset, :message

	def initialize (command, data, code, offset, command_name, message)
		if !command_name.empty? && command.name != command_name.to_sym
			raise ArgumentError, 'the passed command object and the response command name do not match'
		end

		super(command, data)

		@code    = (code.is_a?(Integer) || Integer(code) rescue false) ? Codes.key(code.to_i) : code.to_sym.upcase
		@offset  = offset.to_i
		@message = message

		unless Codes[to_sym]
			raise ArgumentError, 'the Error code does not exist'
		end
	end

	def to_sym
		@code
	end

	def to_i
		Codes[to_sym]
	end
end

end; end
