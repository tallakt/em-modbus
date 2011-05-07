require 'eventmachine'

module EmModbus
	class Connection
		def initialize(options={}) 
			default_options = {
				:host => 'localhost',
				:port => 502,
				:word_max_block_size => 512,
				:coil_max_block_size => 512,
				:connections => 1
			}
			@options = default_options.merge(options)
			@modbus_handlers = []
		end

		def add_modbus_handler(h)
			@modbus_handlers << h unless @modbus_handlers.contains? h
		end
	end
end
