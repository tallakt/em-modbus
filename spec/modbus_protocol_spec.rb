require 'spec_helper'

describe EmModbus::ModbusProtocol do
	context do
		let(:modbus) { ModbusProtocol.new(nil, nil) }

		it 'should be able to send a request for a single word' do
			modbus.should_receive(:send_data).with("\0\0\0\0\0\006\000\003\000\000\000\001")
			modbus.read_registers(0, 1)
		end

		it 'should be send a request to write an array of coils' do
			modbus.should_receive(:send_data).with("\0\0\0\0\0\x08\000\x0F\0\0\0\x08\1\xff")
			modbus.write_coils(0, [true] * 8)

			modbus.should_receive(:send_data).with("\0\0\0\0\0\x0C\000\x0F\x12\x34\0\x21\x05\x11\0\xFF\xFF\x01")
			modbus.write_coils(0x1234, [true, false, false, false] * 2 + [false] * 8 + [true] * 16 + [true])
		end

		it 'should be send a request to write an array of words' do
			modbus.should_receive(:send_data).with("\0\0\0\0\0\x0D\000\x10\x12\x34\0\003\006\0\xFF\xFF\0\xEE\x99")
			modbus.write_registers(0x1234, "\0\xFF\xFF\0\xEE\x99")
		end

		it 'should support different values for unit identifier' do
			modbus.should_receive(:send_data).with("\0\0\0\0\0\006\x64\003\000\000\000\001")
			modbus.read_registers(0, 1, 100)
		end

		it 'should handle a reply for write registers'
		it 'should handle a reply for read registers'
		it 'should handle a reply for write coils'
		it 'should handle a reply for read coils'
		it 'should return an error if asking for address outside physical memory'
		it 'should be able to write to single bits in a word'
	end

	context 'with large limits' do
		let(:modbus) { ModbusProtocol.new(nil, nil, 
																			:max_read_registers => 99999, 
																			:max_write_registers => 99999,
																			:max_read_coils => 99999, 
																			:max_write_coils => 99999) }

		it 'should be able to send a request for an array of words' do
			modbus.should_receive(:send_data).with("\0\0\0\0\0\006\000\003\x12\x34\x56\x78")
			modbus.read_registers(0x1234, 0x5678)
		end

		it 'should be send a request to read an array of coils' do
			modbus.should_receive(:send_data).with("\0\0\0\0\0\x06\000\x01\x12\x34\x01\x15")
			modbus.read_coils(0x1234, 0x0115)
		end
	end

	it 'should accept the slave address option' do
		modbus = ModbusProtocol.new(nil, nil, :slave_address => 100)
		modbus.should_receive(:send_data).with("\0\0\0\0\0\006\x64\003\000\000\000\001")
		modbus.read_registers(0, 1)
	end

	it 'should accept the max size override options' do
		modbus = ModbusProtocol.new(nil, nil, 
																			:max_read_registers => 10, 
																			:max_write_registers => 20,
																			:max_read_coils => 30, 
																			:max_write_coils => 40)
		modbus.should_receive(:send_data).exactly(4).times
		modbus.read_registers(1, 10)
		lambda { modbus.read_registers(1, 11) }.should raise_error
		modbus.write_registers(1, "\0\0" * 20)
		lambda { modbus.write_registers(1, "\0\0" * 21) }.should raise_error
		modbus.read_coils(1, 30)
		lambda { modbus.read_coils(1, 31) }.should raise_error
		modbus.write_coils(1, [false] * 40)
		lambda { modbus.write_coils(1, [false] * 41) }.should raise_error
	end
end
