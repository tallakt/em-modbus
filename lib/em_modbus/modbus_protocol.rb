require 'eventmachine'

module EmModbus
	class ModbusProtocol < EventMachine::Connection
		include EventMachine::Deferrable

		# extracted from the Modbus standard
		MAX_READ_REGISTERS = 125
		MAX_WRITE_REGISTERS = 100
		MAX_READ_COILS = 2000
		MAX_WRITE_COILS = 800

		def initialize(sig, *args)
			@options = {
				:max_read_registers => MAX_READ_REGISTERS,
				:max_write_registers => MAX_WRITE_REGISTERS,
				:max_read_coils => MAX_READ_COILS,
				:max_write_coils => MAX_WRITE_COILS,
			}.merge!(args.first || {})
		end

		def read_registers(start_addr, count, slave_address = default_slave_address)
			if count > @options[:max_read_registers]
				raise "too many words, max #{@options[:max_read_registers]}"
			end
			send_data(create_packet(0x03, [start_addr, count].pack('nn'), slave_address))
		end

		def write_registers(start_addr, raw_data, slave_address = default_slave_address)
			if raw_data.bytesize > @options[:max_write_registers] * 2
				raise "too many words, max #{@options[:max_write_registers]}"
			end
			send_data(create_packet(0x10, [start_addr, raw_data.size / 2, raw_data.size].pack('nnC') + raw_data, slave_address))
		end

		def read_coils(start_addr, count, slave_address = default_slave_address)
			if count > @options[:max_read_coils]
				raise "too many coils, max #{@options[:max_read_coils]}"
			end
			send_data(create_packet(0x01, [start_addr, count].pack('nn'), slave_address))
		end

		def write_coils(start_addr, values, slave_address = default_slave_address)
			if values.size > @options[:max_write_coils]
				raise "too many words, max #{@options[:max_write_coils]}"
			end
			vv = values.map {|v| if v then '1' else '0' end }.pack('b*')
			send_data(create_packet(0x0f, [start_addr, values.size, vv.bytesize].pack('nnC') + vv, slave_address))
		end

		def create_packet(function_code, data, slave_address) # :nodoc:
			[0, 0, data.size + 2, slave_address, function_code].pack('nnnCC') + data
		end
		private :create_packet

		def default_slave_address # :nodoc:
			(@options && @options[:slave_address]) || 0
		end
		private :default_slave_address
	end
end
