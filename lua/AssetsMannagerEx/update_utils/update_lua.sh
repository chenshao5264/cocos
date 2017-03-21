#!/bin/bash

cd /Users/chenshao/Documents/Cocos/87game/client_uno/uno/code/

if [ -d hotupdate ]; then
rm -rf hotupdate 
mkdir hotupdate
else
mkdir hotupdate
fi

echo "----------------  正在拷贝 -------------"
cp -r ./src ./hotupdate
cp -r ./res ./hotupdate
echo "---------------- 完成拷贝 -------------"

#删除.DS_Store
find ./hotupdate -name *.DS_Store|xargs rm -rf
rm ./hotupdate/res/project.manifest
rm ./hotupdate/res/version.manifest

echo "---------------- 开始生成 配置文件-------------"
#每次运行版本号最后一位自+1
#文件格式必须保证正确，此脚本不做任何检测
pre_verion="1.0."
verionText=/Users/chenshao/Documents/Cocos/cocos-libs/cocos-better/AssetsMannagerEx/update_utils/version.text
#读取文件第一行作为版本号的最后一位
build=`head -1 $verionText` 
version=$pre_verion$build
#自+1
newVersion=$(($build+1))
echo $newVersion > $verionText

#unoupdate.87dianwan.com:36361
#192.168.3.67:3000
export URL=http://192.168.3.67:3000/scripts/
export VERSION=$version
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

scripts=/Users/chenshao/Desktop/nodejs/develop/nodeUNO/public/scripts
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


