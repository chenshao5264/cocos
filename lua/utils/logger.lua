--
-- Author: Your Name
-- Date: 2017-06-19 09:48:22
--
local logger = {}

local fileUtils = cc.FileUtils:getInstance()

logger.LEVEL_MIN   = 0
logger.LEVEL_DEBUG = 1
logger.LEVEL_INFO  = 2
logger.LEVEL_WARN  = 3
logger.LEVEL_ERROR = 4
logger.LEVEL_MAX   = 5

logger.level = logger.LEVEL_MIN

local function write2File(loggertype, string)
	local fileName = string.format("./logger/logger_%s.txt", loggertype)

	local file = io.open(fileName, "a")
	file:write(os.date("%Y-%m-%d %H:%M:%S") ..": " ..string)
	file:write("\n")
	file:close()
end

local function createDir()
	local loggerDir = fileUtils:getWritablePath() .."/logger"
	if not fileUtils:isDirectoryExist(loggerDir) then
		fileUtils:createDirectory(loggerDir)
	end
end

local function checkInfoType(info, dumpName, nesting)
	if type(info) == "table" then
		dumpName = tostring(dumpName)
		nesting  = nesting or 5
		local result = dump(info, dumpName, nesting)
		info = table.concat(result, "\n")
	else
		info = tostring(info)
	end

	return info
end

function logger.debug(info, isWrite2File, dumpName, nesting)

	if logger.LEVEL_DEBUG < logger.level  then
		return
	end

	info = checkInfoType(info, dumpName, nesting)

	print("<====== debug = " ..info)

	if isWrite2File then
		createDir()
		write2File("debug", info)
	end
end

function logger.info(info, isWrite2File, dumpName, nesting)
	if logger.LEVEL_INFO < logger.level  then
		return
	end

	info = checkInfoType(info)

	print("<====== info = " ..info)

	if isWrite2File then
		createDir()
		write2File("info", info)
	end
end

function logger.warn(info, isWrite2File, dumpName, nesting)
	if logger.LEVEL_WARN < logger.level  then
		return
	end

	info = checkInfoType(info)

	print("<====== warn = " ..info)
	
	if isWrite2File then
		createDir()
		write2File("warn", info)
	end
end

function logger.error(info, isWrite2File, dumpName, nesting)
	if logger.LEVEL_ERROR < logger.level  then
		return
	end

	info = checkInfoType(info)

	print("<====== error = " ..info)
	
	if isWrite2File then
		createDir()
		write2File("error", info)
	end
end



return logger