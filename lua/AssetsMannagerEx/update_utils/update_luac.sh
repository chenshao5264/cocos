#!/bin/bash

cd /Users/chenshao/Documents/Cocos/87game/client_uno/uno/code/

if [ -d hotupdate ]; then
rm -rf hotupdate 
mkdir hotupdate
else
mkdir hotupdate
fi

echo "---------------- 开始加密 -------------"
/Users/chenshao/Documents/Cocos/quick-lua/quick-3.5/tools/cocos2d-console/bin/cocos luacompile -s ./src -d ./hotupdate/src -e -k key-zjzy2016.. -b sign-zjzy2016.. --disable-compile
cp -r ./src/ ./hotupdate/src
#cp -r ./src/ ./src_copy
find ./hotupdate/src -name *.lua|xargs rm -rf
cp -r ./res ./hotupdate
echo "---------------- 完成加密 -------------"

#删除.DS_Store
find ./hotupdate -name *.DS_Store|xargs rm -rf
rm ./hotupdate/res/project.manifest
rm ./hotupdate/res/version.manifest

echo "---------------- 开始生成 配置文件-------------"
export URL=http://localhost:3000/uno/
export VERSION=1.0.0
export WALKDIR=./hotupdate
export OUT_DIR=./hotupdate
export EXCLUDE_DIR=./hotupdate/src/apis
node /Users/chenshao/Documents/Cocos/cocos-libs/cocos-better/AssetsMannagerEx/update_utils/lfsHelper
echo "---------------- 完成生成 配置文件-------------"




#echo "---------------- 开始压缩 -------------"
#if [ -f hotupdate.zip ]; then
#rm hotupdate.zip
#fi
#zip -r hotupdate.zip ./hotupdate
#echo "---------------- 完成压缩 -------------"