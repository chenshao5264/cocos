//
//  packet.h
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/12.
//
//

#ifndef packet_h
#define packet_h


#define CC_CALLBACK_4(__selector__,__target__, ...) std::bind(&__selector__,__target__, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, ##__VA_ARGS__)

#define SOCKET_TCP_BUFFER	16384									//网络缓冲
#define SOCKET_TCP_PACKET	(SOCKET_TCP_BUFFER-sizeof(TCP_Head))	//网络缓冲

typedef unsigned short		WORD;
typedef unsigned char		BYTE;

#pragma mark 内核命令
#define MDM_KN_COMMAND			0						//内核命令
#define SUB_KN_DETECT_SOCKET	1						//检测命令
#define SUB_KN_VALIDATE_SOCKET	2						//验证命令

//数据分类
typedef enum _DataType
{
    Data_Default	= 0,		//默认
    Data_Load		= 1,		//登录命令
    Data_Room		= 2,		//房间命令
    Data_End		= 10,		//结束
}DataType;

//网络内核
struct TCP_Info
{
    BYTE		cbDataKind;						//数据类型
    BYTE		cbCheckCode;					//效验字段
    WORD		wPacketSize;					//数据大小
};

//网络命令
typedef struct
{
    WORD		wMainCmdID;						//主命令码
    WORD		wSubCmdID;						//子命令码
}TCP_Command;

//网络包头
typedef struct
{
    TCP_Info	TCPInfo;						//基础结构
    TCP_Command	CommandInfo;					//命令信息
}TCP_Head;

//网络缓冲
typedef struct
{
    TCP_Head	Head;							//数据包头
    BYTE		cbBuffer[SOCKET_TCP_PACKET];	//数据缓冲
}TCP_Buffer;

#endif /* packet_h */
