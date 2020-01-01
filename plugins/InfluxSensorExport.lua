-- Script to filter out sensor values

local debug = true			-- Print debug data to console
local verbose = false			-- Print even more debug data

function onInit()
	print("Sending sensor values to influx-DB via Plugin %s", os.date("%Y-%m-%d %X"))
	local ifx = require "influx.DB"
	if ifx == nil then
		print("Influx sender plugin is not installed")
		return
	end
end


function onSensorValueUpdated(device, valueType, value, scale)
	if verbose == true then
		print("debug %s", os.date("%Y-%m-%d %X", os.time()))
		print("Device %s id:, %s, value %s type:%s scale:%s",  device:name(), device:id(), value, valueType, scale)
		print("--")
	end

	local ifx = require "influx.DB"
	if ifx == nil then
		print("Influx sender plugin is not installed")
		return
	end
	if device:name() == nil or device:name() == "" then
		return
	end
	local sc_str  = string.format("%s", scale)
	local meas = 'misc'

	if device:id() > 80 and device:id() < 85 then
		meas = 'heating'
	elseif valueType == 1 then
		meas = 'temperature'
	elseif valueType == 2 then
		meas = 'humidity'
	elseif valueType == 4 or valueType == 8 then
		meas = 'rain'
	elseif valueType >= 16 then
		meas = 'weather'
	end

    ifx:send{
        measurment=meas,
        location='indoor',
        devname=device:name(),
        devid=device:id(),
        data=value,
        datatype=valueType,
        scale=sc_str
    }
end
