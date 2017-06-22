
local Config = {
    synclog         = false,                        -- 是否同步print日志到webserver
    logserver       = "192.168.8.7",                -- webserver地址(某台测试机)
    --logserver       = "139.224.117.95",             -- (wy的服务器)
    gmenable        = true,                         -- 是否连接指令服务器
    gmserver        = "139.224.117.95:7777",        -- 指令服务器地址
}

--Config.bWin32 = device.platform == "windows"      -- 启用这个标志时，win32下日志比较简单，1级目录, 日志文件名为userid, 重启模拟器会覆盖重写；不会同步日志到webserver

return Config
