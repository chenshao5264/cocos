## 基于htmlxml格式创建可换行的富文本

## 用法

local htmlText = require("HtmlText").new()
htmlText:renderFile("level_introduce.xml")

## or

local xmlText = "<font color='ffffff' size='30' opacity='255'><font color='ff0000' face='happyfont.ttf'>你好</font><font color='00ff00'>jikexueyuan</font><br/>新<br/><font color='0000ff'>的</font>行<br/>又是新的一行</font>"
htmlText:renderHtml(xmlText)

## 新增图片显示，图片高度必须人为与文字高度一样，或者小。暂不支持自动调节
