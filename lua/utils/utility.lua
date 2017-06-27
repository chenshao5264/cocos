--
-- Author: Your Name
-- Date: 2017-06-22 13:39:37
--

local utility = {}

function utility.hex2Rgb(strHex)
	strHex = string.gsub(strHex, "#", "")
	local r = tonumber("0x" ..string.sub(strHex, 1, 2))
	local g = tonumber("0x" ..string.sub(strHex, 3, 4))
	local b = tonumber("0x" ..string.sub(strHex, 5, 6))
	return cc.c3b(r, g, b)
end

function utility.time()
    return os.date("*t", os.time())
end

return utility