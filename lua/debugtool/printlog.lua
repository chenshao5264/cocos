
local fileutils = cc.FileUtils:getInstance()

local function getLogDir()
    local dir = device.writablePath .. "/pntlog/"
    if not fileutils:isDirectoryExist(dir) then
         fileutils:createDirectory(dir)
    end

    if gDbgConfig.bWin32 then
        return dir
    end

    dir = dir .. os.date("%Y%m%d/")
    if not fileutils:isDirectoryExist(dir) then
         fileutils:createDirectory(dir)
    end
    return dir
end

local function updateFileList(szNewFile)
    local path = getLogDir() .. "filelist.txt"
    if szNewFile == "temp.txt" and fileutils:isFileExist(path) then
        return
    end
    local f = io.open(path, "a")
    f:write(szNewFile .. "\n")
    f:close()
end

local function getFileListByDate(szDate)
    local dir = string.format("%s/pntlog/%s/", device.writablePath, szDate)
    local path = dir .. "filelist.txt"
    if fileutils:isFileExist(path) then
        local list = {}
        local f = io.open(path, "r")
        while true do
            local line = f:read("*line")
            if not line then break end
            if fileutils:isFileExist(dir .. line) then
                table.insert(list, line)
            end
        end
        f:close()
        return list
    end
    return {}
end
cc.exports.getFileListByDate = getFileListByDate

local userFile
cc.exports.gCurLogPath = getLogDir() .. "temp.txt"
local tempFile = io.open(gCurLogPath, "w")
updateFileList("temp.txt")

local function writeToFile(szStr)
    if not DbgInterface then
        return  
    end
    
    if not userFile then
        local nPlayerId = DbgInterface:getPlayerId()
        if nPlayerId and nPlayerId > 0 then
            if not userFile then
                local fileName = string.format("%s_%s.txt", nPlayerId, os.date("%H%M%S"))
                if gDbgConfig.bWin32 then
                    fileName = string.format("%s.txt", nPlayerId)
                end
                cc.exports.gCurLogPath = getLogDir() .. fileName
                userFile = io.open(gCurLogPath, "w")
                updateFileList(fileName)
            end
        end
    end

    local f = userFile or tempFile
    f:write(szStr)
    f:flush()
end

local function concat(...)
    local tb = {}
    for i=1, select('#', ...) do
        local arg = select(i, ...)  
        tb[#tb+1] = tostring(arg)
    end
    return table.concat(tb, "\t")
end

local old_print = print
function print(...)
    local pntRet = os.date("[%H:%M:%S] ") .. concat(...) .. "\n"
    writeToFile(pntRet)

    if not gDbgConfig.bWin32 and DbgInterface then
        DbgInterface:uploadPrintLog(pntRet)
    end

    old_print(...)
end

if release_print then
    local old_release_print = release_print
    function release_print(...)
        local pntRet = os.date("[%H:%M:%S] ") .. concat(...) .. "\n"
        writeToFile(pntRet)

        if not gDbgConfig.bWin32 and DbgInterface then
            DbgInterface:uploadPrintLog(pntRet)
        end

        old_release_print(...)
    end
end

cc.exports.writeTestLog = function(...)
    local path = getLogDir() .. "test.log"
    local f = io.open(path, "a")
    f:write(concat(...) .. "\n")
    f:close()
end
