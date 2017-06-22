local LocalizationManager = class("LocalizationManager")
LocalizationManager.NEED_LOAD = {"locale/dialog_string.properties"}
function LocalizationManager:ctor()
    self.mLocaler = require("app.i18n.init")
    self.mLocaler.setLocale("zh_CN")
    for _,fileName in pairs(LocalizationManager.NEED_LOAD) do
        fileName = cc.exports.Global:getFileName(fileName)
        fileName = cc.FileUtils:getInstance():fullPathForFilename(fileName)
        print(fileName)
        local content = cc.FileUtils:getInstance():getStringFromFile(fileName)
		if content then
			local jsonData =  json.decode(content)
            self.mLocaler.load(jsonData)
            self.data=jsonData
		end

    end
end

function LocalizationManager:getLocaleString(key,param)
    param = param or {default = "no config"}
    return self.mLocaler.translate(key,param)
end

function LocalizationManager:getLocaleStringByValue(key, value)
   return self:getLocaleString(key, {value = value})
end

return LocalizationManager
