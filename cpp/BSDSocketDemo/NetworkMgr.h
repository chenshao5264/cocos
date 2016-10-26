//
//  NetworkMgr.hpp
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/12.
//
//

#ifndef NetworkMgr_hpp
#define NetworkMgr_hpp

#include "cocos2d.h"
#include "packet.h"
#include "TCPSocket.h"


class CTCPSocket;
class CNetworkMgr : cocos2d::Ref
{
public:
    ~CNetworkMgr();
    static CNetworkMgr* getInstance();
    
    //网络连接
    void doConnect(const char* domain, WORD wPort, DataType type);
    
    void Disconnect(DataType type);
    
    //消息接收
    void SocketDelegateWithRecvData(void* socket, void* pData, WORD wSize, bool isinBack);    //消息处理
    
    void sendData(WORD wMainCmdID, WORD wSubCmdID, char* buffer, WORD wSize, CTCPSocket* socket = nullptr);

    //网络变量
    CC_SYNTHESIZE(CTCPSocket*, m_pSocketData, SocketData)//长时连接
    
protected:
    CNetworkMgr();
    
private:

};


#endif /* NetworkMgr_hpp */
