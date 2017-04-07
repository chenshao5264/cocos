#!/bin/bash

target=$1
ROMATE=$2

if [ "$target" = "android" ]; then
	echo "android"
else
	echo "ios"
	target=ios
fi

if [ "$ROMATE" = "" ]; then
	ROMATE=http://192.168.3.67:3000	
fi

cd /Users/chenshao/Documents/Cocos/87game/client_uno/uno/code/


if [ -d hotupdate ]; then
	find ./hotupdate -name *.DS_Store|xargs rm -rf
	rm -rf hotupdate 
	mkdir hotupdate
else
	mkdir hotupdate
fi

echo "----------------  正在拷贝 -------------"
cp -r ./src ./hotupdate
cp -r ./res ./hotupdate
echo "---------------- 完成拷贝 -------------"

if [ "$target" = "android" ]; then
	echo "---------------- 开始加密 -------------"
	/Users/chenshao/Documents/Cocos/quick-lua/quick-3.5/tools/cocos2d-console/bin/cocos luacompile -s ./src -d ./hotupdate/src -e -k key-zjzy2016.. -b sign-zjzy2016.. --disable-compile
	cp -r ./src/ ./hotupdate/src
	find ./hotupdate/src -name *.lua|xargs rm -rf
	cp -r ./res ./hotupdate
	echo "---------------- 完成加密 -------------"
fi

#删除.DS_Store
find ./hotupdate -name *.DS_Store|xargs rm -rf
rm ./hotupdate/res/project.manifest
rm ./hotupdate/res/version.manifest

echo "---------------- 开始生成 配置文件-------------"
#每次运行版本号最后一位自+1
#文件格式必须保证正确，此脚本不做任何检测
pre_verion="1.0."
verionText=/Users/chenshao/Documents/Cocos/cocos-libs/cocos-better/AssetsMannagerEx/update_utils/version_$target.text
#读取文件第一行作为版本号的最后一位
build=`head -1 $verionText` 
version=$pre_verion$build
#自+1
newVersion=$(($build+1))
echo $newVersion > $verionText

export URL=$ROMATE/scripts/$target/
export PRE_PATH=/Users/chenshao/Documents/Cocos/87game/client_uno/uno/code/
export VERSION=$version
export WALKDIR=./hotupdate
export OUT_DIR=./hotupdate
export EXCLUDE_DIR=./hotupdate/src/apis
export TARGET=$target
node /Users/chenshao/Documents/Cocos/cocos-libs/cocos-better/AssetsMannagerEx/update_utils/lfsHelper
echo "---------------- 完成生成 配置文件-------------"

cp -f ./hotupdate/project.manifest ./res/
cp -f ./hotupdate/version.manifest ./res/

scripts=/Users/chenshao/Desktop/nodejs/develop/nodeUNO/public/scripts/$target
rm -rf $scripts
if [ -d $scripts ]; then
	rm -rf $scripts
	mkdir $scripts
else
	mkdir $scripts
fi

echo "----------------  正在拷贝至本地服务器 -------------"
cp -r ./hotupdate/ $scripts
echo "---------------- 完成拷贝 -------------"
echo ""



