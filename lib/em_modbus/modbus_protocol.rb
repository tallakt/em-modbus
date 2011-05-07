require 'eventmachine'

module EmModbus
	class ModbusProtocol < EventMachine::Connection
		include EventMachine::Deferrable

		MAX_READ_REGISTERS = 125
		MAX_WRITE_REGISTERS = 100
		MAX_READ_COILS = 2000
		MAX_WRITE_COILS = 800

		def initialize(*args)
			@options = {
				:slave_address => 0,
				:max_read_reg => MAX_READ_REGISTERS,
				:max_write_reg => MAX_WRITE_REGISTERS,
				:max_read_coils => MAX_READ_COILS,
				:max_write_coils => MAX_WRITE_COILS,
			}.merge!(args.first || {})
		end

		def new_transaction_identifier # :nodoc:
			@transaction_identifier ||= 0
			@transaction_identifier = (@transaction_identifier + 1) & 0xffff
		end

		def read_registers(start_addr, count)
			if count > @options[:max_read_registers]
				raise "too many words, max #{@options[:max_read_registers]}"
			end
			send_data(create_packet(0x03, [start_addr, count].pack('nn'))
		end

		def write_registers(start_addr, raw_data)
			if raw_data.bytesize > @options[max_write_registers] * 2
				raise "too many words, max #{@options[max_write_registers]}"
			end
			send_data(create_packet(0x10, [start_addr, raw_data.size / 2, raw_data.size].pack('nnC') + raw_data)
		end

		def read_coils(start_addr, count)
			if count > @options[:max_read_coils]
				raise "too many coils, max #{@options[:max_read_coils]}"
			end
			send_data(create_packet(0x01, [start_addr, count].pack('nn'))
		end

		def write_coils(start_addr, values)
			if values.size > @options[max_write_coils]
				raise "too many words, max #{@options[max_write_coils]}"
			end
			vv = values.map {|v| s << (v ? '1' : 0) }.join.pack('b*')
			send_data(create_packet(0x0f, [start_addr, values.size, vv.bytesize].pack('nnC') + vv)
		end

		def create_packet(function_code, data) # :nodoc:
			[new_transaction_identifier, 0, data.size + 2, slave_address, function_code].pack('nnnCC') + data
		end
		private :create_packet

		def slave_address # :nodoc:
			@options[:slave_address]
		end
		private :slave_address
	end
end

