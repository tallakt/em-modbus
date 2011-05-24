require 'eventmachine'

module EmModbus
	class Device
		def initialize(options={}) 
			default_options = {
				:host => 'localhost',
				:port => 502,
				:connections => 1
			}
			@options = default_options.merge(options)
		end


		def image(image_options = {})
			Image.new image_options
		end
	end
end
