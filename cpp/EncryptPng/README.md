# Encrypt PNG
PNG格式图片加密解密工具，可以很方便地嵌入到cocos2d-x游戏引擎中。加密是通过剔除数据块的长度和类型码来实现的。实现简单，解密高效，可以有效地提高游戏资源被破解的门槛。

# 运行环境
由于使用了windows的api，加密程序只支持windows系统。解密程序可在任意支持c++11编译器的平台上使用。

# 如何使用
你可以[直接下载](https://github.com/zhangpanyi/encrypt-png/tree/master/cpp/Release)已经编译好的加密和解密程序，如果无法运行你可以自己编译源代码来生成程序。

加密PNG图片，把 EncryptPNG.exe 文件放到图片所在的文件目录里面执行，然后输入密钥就可以了。然后它就会自动加密所在目录及其子目录的所有PNG图片，并在生成对应的 .epng 文件。

如果想要验证文件是否能够成功解密，只需打开命令窗口，输入 DecryptPNG.exe xxx.epng，然后输入密钥。如果密钥正确的话就会生成一个 .png 文件。


PS:
在原作者的基础上，添加了 cocostudio 导出资源解密的功能
包括合图和碎图

其中 密钥对应的文件在CCDecryptImagec.pp
static const aes_key DEAULT_KEY = { 0x31, 0x32, 0x33, 0x34, 0x31, 0x32, 0x33, 0x34, 0x31, 0x32, 0x33, 0x34, 0x31, 0x32, 0x33, 0x34};
“123412341234”
字段为ASCII对应的16个字段