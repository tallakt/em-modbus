require 'em/protocols/socks4'

module Modbus
	class Connection
		def initialize(options={}) 
			default = {
				:host => 'localhost',
				:port => 502
			}
		end
	end
end
