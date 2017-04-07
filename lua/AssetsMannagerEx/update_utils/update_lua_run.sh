#!/bin/bash

URL=http://unoupdate.87dianwan.com:36361
#URL=http://192.168.3.67:3000

echo "----------------  android -------------"
/Users/chenshao/Documents/Cocos/cocos-libs/cocos-better/AssetsMannagerEx/update_utils/update_lua.sh "android" $URL
echo "----------------  android 完毕-------------"


echo "----------------  ios -------------"
/Users/chenshao/Documents/Cocos/cocos-libs/cocos-better/AssetsMannagerEx/update_utils/update_lua.sh "ios" $URL
echo "----------------  ios 完毕-------------"



