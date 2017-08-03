
-- extensions
require "cocos.extension.ExtensionConstants"
-- network
require "cocos.network.NetworkConstants"


local function run()
    cc.exports.gDbgConfig = require("debugtool.config")
    require("debugtool.globalfunc")
    require("debugtool.printlog")

    require("debugtool.dbginterface")
    DbgInterface:run()
end

local status, msg = xpcall(run, function(s)
    print(debug.traceback(s,2))
    return s
end)
