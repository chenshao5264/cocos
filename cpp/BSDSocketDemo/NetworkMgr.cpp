//
//  NetworkMgr.cpp
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/12.
//
//

#include "NetworkMgr.h"


static CNetworkMgr* s_pCNetworkMgr = nullptr;

CNetworkMgr::CNetworkMgr()
{
    
}

CNetworkMgr::~CNetworkMgr()
{
}

CNetworkMgr* CNetworkMgr::getInstance()
{
    if (s_pCNetworkMgr == nullptr)
    {
        s_pCNetworkMgr = new CNetworkMgr();
    }
    return s_pCNetworkMgr;
}

void CNetworkMgr::doConnect(const char* domain, WORD wPort, DataType type)
{
    CTCPSocket *socket = new  CTCPSocket();
   // this->Disconnect(type);
    
    m_pSocketData = socket;
    
    socket->socketConnect(domain, wPort, type);
    socket->setSocketTarget(CC_CALLBACK_4(CNetworkMgr::SocketDelegateWithRecvData, this));
    
}

void CNetworkMgr::Disconnect(DataType type)
{
    if (m_pSocketData)
    {
        m_pSocketData->socketClose();
        m_pSocketData->autorelease();
    }
    m_pSocketData = nullptr;
}

//消息接收
void CNetworkMgr::SocketDelegateWithRecvData(void* socket, void* pData, WORD wSize, bool isinBack)
{
    char* buf = (char*)pData;
    CCLOG("receive data from server");
}

void CNetworkMgr::sendData(WORD wMainCmdID, WORD wSubCmdID, char* buffer, WORD wSize, CTCPSocket* socket)
{
    CTCPSocket* pSocket = socket;
    if (socket == nullptr)
    {
        pSocket = m_pSocketData;
    }
    
    if(pSocket)
    {
        //TCP_Buffer tcp_buffer;
        //memset(&tcp_buffer,0,sizeof(TCP_Buffer));
        //tcp_buffer.Head.CommandInfo.wMainCmdID=wMainCmdID;
        //tcp_buffer.Head.CommandInfo.wSubCmdID=wSubCmdID;
        
        //memcpy(&tcp_buffer.cbBuffer, buffer, wSize);
        
        //pSocket->socketSend((char*)&buffer, wSize + sizeof(TCP_Head));
        pSocket->socketSend(buffer, wSize);
    }
}
