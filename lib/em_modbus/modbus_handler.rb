require 'eventmachine'

module EmModbus
	class ModbusHandler < EventMachine::Connection
		def initialize(connection)
			@connection = connection
			connection.add_modbus_handler self
		end

		def read_registers(address, count, &callback)
			@callback = callback
		end


		def receive_data(data)
			@callback.call data
		end


	end
end

