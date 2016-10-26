//
//  TCPSocket.cpp
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/12.
//
//

#include "TCPSocket.h"
#include "SocketRecvData.h"

using namespace cocos2d;
using namespace std;

void *threadSocketRecv(void* param)
{
    // 接收消息
    CTCPSocket* socket = (CTCPSocket*)param;
    
    while (socket->getLoop())
    {
        if (socket->getConnectType() == unConnect)
        {
            socket->setConnectType(Connecting);
            std::string sdomain(socket->getDomain());
            CCLOG("网络连接地址 %s", socket->getDomain().c_str());
            bool ret = socket->getSocket()->Connect(socket->getDomain().c_str(), socket->getwPort());
            if (ret)
            {
                socket->setHeartTime(0.f);
                socket->setConnectType(Connected);
            }
            else
            {
                CCLOG("fail to connect server");
                socket->setConnectType(Connect_Faild);
                break;
            }
        }
        else if(socket->getConnectType() == Connected)
        {
            if (!socket->socketRecv())
            {
                break;
            }
        }
        sleep(1.0 / 60.0f);
    }
    
    pthread_exit(NULL);
    return 0;
}

CTCPSocket* CTCPSocket::create()
{
    CTCPSocket* socket = new CTCPSocket();
    socket->autorelease();
    return socket;
}

CTCPSocket::CTCPSocket()
: m_heartTime(0.f)
, m_connecttype(unConnect)
, m_NoMessageTime(0.f)
{
    m_hThread = 0;
    m_bLoop = true;
    m_bConnect = false;
    m_pSocket = NULL;
    
    m_bEntry = true;
    m_DataType = Data_Load;
    m_wSize = 0;
    m_Recv = nullptr;
    memset(m_pData, 0, sizeof(m_pData));
    Director::getInstance()->getScheduler()->schedule(CC_SCHEDULE_SELECTOR(CTCPSocket::RecvDataUpdate), this, 0, false);
}

CTCPSocket::~CTCPSocket()
{
    m_recvdataQueue.clear();
}

void CTCPSocket::setSocketTarget(gameMessageRecv recv)
{
    m_Recv = recv;
}


bool CTCPSocket::socketConnect(const char *domain, WORD wPort, DataType type , bool isLoop)
{
    m_pSocket = new CBSDSocket();
    m_pSocket->Init();
    m_pSocket->Create(AF_INET, SOCK_STREAM);
    
    //连接方式
    m_bLoop = isLoop;
    m_DataType = type;
    memset(m_pData, 0, sizeof(m_pData));
    m_domain = domain;
    m_wport = wPort;
    this->threadCreate();
    
    return true;
}

void CTCPSocket::RecvDataUpdate(float time)
{
    int type = m_connecttype;
    if (type == unConnect)
    {
        return;
    }
    
    if (type == Connecting)
    {
        m_heartTime += time;
        if (m_heartTime > 30.0f)
        {
            this->Disconnettologin("connect time out");
            Director::getInstance()->getScheduler()->unschedule(CC_SCHEDULE_SELECTOR(CTCPSocket::RecvDataUpdate), this);
            this->socketClose();
        }
        return;
    }
    
    if (type == Connect_Faild)
    {
        this->connetfaildDeal();
        return;
    }
    
    if (type == Connect_Kick_Out)
    {
        this->Disconnettologin("nectwork kick out");
        Director::getInstance()->getScheduler()->unschedule(CC_SCHEDULE_SELECTOR(CTCPSocket::RecvDataUpdate), this);
        this->socketClose();
        return;
    }
    
    cocos2d::Vector<RecvData* > vectordata;
    RecvData* rdata = nullptr;
    
    recvdatamutex.lock();
    
    if (m_recvdataQueue.empty())
    {
        m_heartTime += time;
        m_NoMessageTime += time;
        recvdatamutex.unlock();
        
        if (m_heartTime > 10)
        {
            TCP_Buffer heartBuffer;
            memset(&heartBuffer, 0, sizeof(TCP_Buffer));
            heartBuffer.Head.CommandInfo.wMainCmdID = MDM_KN_COMMAND;
            heartBuffer.Head.CommandInfo.wSubCmdID = SUB_KN_DETECT_SOCKET;
            this->socketSend((char*)&heartBuffer, strlen((char*)&heartBuffer));
            m_heartTime = 0;
        }
        return;
    }
    else
    {
        vectordata = m_recvdataQueue;
        m_recvdataQueue.clear();
        recvdatamutex.unlock();
        m_heartTime = 0;
        m_NoMessageTime = 0.f;
    }
    
    while (vectordata.size() != 0)
    {
        rdata = vectordata.at(0);
        if (rdata)
        {
            int datasize = rdata->getDatasize();
            // 在网络失效的时候 不直接发送消息到服务器 而是pushback到m_recvdataQueue中
            // 在下次成功连接后，自动发送到服务器
            // 对应 socketSend中得if(m_connecttype != Connected) 分句
            if (rdata->getdataType() == Send_Data)
            {
                this->socketSend(rdata->getRecvData(), datasize);
            }
            else
            {
                if (m_Recv)
                {
                    m_Recv(this, rdata->getRecvData(), datasize, rdata->getIsInBack());
                }
            }
            vectordata.erase(0);
        }
    }
}

void CTCPSocket::connetfaildDeal()
{
    int code = this->getSocket()->GetError();
    switch (code)
    {
        case ECONNREFUSED:
        {
            CCLOG("CTCPSocket: 服务器拒绝，无法响应，请留意系统公告。");
        }
            break;
        case ETIMEDOUT:
        {
            CCLOG("CTCPSocket: 服务器连接超时，请稍后重试");
        }
            break;
        case ECONNRESET:
        {
            CCLOG("CTCPSocket: 连接被强制关闭，请注意操作是否非法。");
        }
            break;
        case ENETUNREACH:
        {
            CCLOG("CTCPSocket: 服务器无法响应，请留意系统公告。");
        }
            break;
        case EHOSTUNREACH:
        {
            CCLOG("CTCPSocket: 无网络连接，请检查网络状况");
        }
            break;
        case 0:
        case EINVAL:
        {
            CCLOG("CTCPSocket: 无网络连接");
        }
            break;
        case ENOENT:
        {
            CCLOG("CTCPSocket: 服务器无响应，请留意系统公告后重试");
        }
            break;
        default:
        {
            
        }
        break;
    }
    
    Director::getInstance()->getScheduler()->unschedule(CC_SCHEDULE_SELECTOR(CTCPSocket::RecvDataUpdate), this);
    this->Disconnettologin("无网络连接，请检查网络状况");
    this->socketClose();
}

void CTCPSocket::Disconnettologin(const string& str)
{
    CCLOG("系统提示: %s", str.c_str());
    // todo
}

//关闭socket
void CTCPSocket::socketClose()
{
    if (m_connecttype == unConnect)
    {
        return;
    }
    m_bConnect = false;
    if (m_hThread)
    {
        pthread_cancel(m_hThread);
        m_hThread = 0;
    }
    
    m_bLoop = false;
    m_wSize = 0;
    
    Director::getInstance()->getScheduler()->unschedule(CC_SCHEDULE_SELECTOR(CTCPSocket::RecvDataUpdate), this);
    
    //关闭socket
    if (m_pSocket)
    {
        m_pSocket->Clean();
        m_pSocket->Close();
        CC_SAFE_DELETE(m_pSocket);
    }
    this->threadClosed();
    m_connecttype = unConnect;
    m_NoMessageTime = .0f;
}

//消息接收
bool CTCPSocket::socketRecv()
{
    if (m_pSocket == nullptr)
    {
        return false;
    }
    
    int nSize = m_pSocket->Recv(m_pData + m_wSize, SOCKET_TCP_BUFFER - m_wSize);
    
    if (nSize == -1)
    {
        if (m_pSocket == nullptr)
        {
            return false;
        }
        if (m_connecttype == Connected)
        {
            m_connecttype = Connect_Kick_Out;
        }
        return false;
    }
    if (nSize == 0)
    {
        return false;
    }
    
    if (nSize != 0)
    {
        CCLOG("接收长度%d",nSize);
        m_wSize += nSize;
    }
    
    
    // test
    RecvData *rdata = new RecvData(m_pData, nSize);
    recvdatamutex.lock();
    m_recvdataQueue.pushBack(rdata);
    recvdatamutex.unlock();
    rdata->release();
    //
    
    //wh协议映射
    if (false)
    //if(m_bEntry)
    {
        while ( m_wSize >= sizeof(TCP_Head) )
        {
            //取出前8字节数据
            char headChar[8];
            memset(headChar,0,sizeof(headChar));
            memcpy(headChar,m_pData,8);
            
            
            
            
            //取的数据长度
            TCP_Head* head = (TCP_Head*)headChar;
            WORD wCurSize = head->TCPInfo.wPacketSize;
            
            //长度效验，小于包头 或者 大于当前数据总长度,说明只接收了一半数据，跳出处理
            if( wCurSize<sizeof(TCP_Head) || wCurSize>m_wSize){
                break;
            }
            
            //取的当前长度 开始处理
            char curBuffer[wCurSize];
            
            memset(curBuffer,0,sizeof(curBuffer));
            memcpy(curBuffer,m_pData,wCurSize);
            
            //数据映射
            if( !unMappedBuffer(curBuffer,wCurSize)){
                CCLOG("数据隐射错误");
                break;
            }
            
            CCLOG("处理长度:%d",wCurSize);
            RecvData *rdata = new RecvData(curBuffer, wCurSize);
            rdata->setIsInBack(false);
            recvdatamutex.lock();
            m_recvdataQueue.pushBack(rdata);
            recvdatamutex.unlock();
            rdata->release();
            
            //减去已处理长度
            m_wSize -= wCurSize;
            
            //数据移动
            memmove(m_pData, m_pData+wCurSize, m_wSize);
            
            //跳出判断
            if( m_wSize<sizeof(TCP_Head) ){
                CCLOG("处理完一次数据－－－－－－－－－－－－－－－－－－－－－－");
                break;
            }
        }
    }
    
    //其他映射
    else
    {
        //直接处理
        //if(m_pTarget && m_pTarget->SocketDelegateWithRecvData(this, m_pData, m_wSize))
        {
            
            
        }
    }
    return true;

    
    return true;
}

bool CTCPSocket::socketSend(char* pData, WORD wSize)
{
    //数据大包
    
    if (m_pSocket == nullptr)
    {
        return false;
    }
    if(m_connecttype == Connect_Kick_Out)
    {
        return false;
    }
    
    if(m_connecttype != Connected)
    {
        RecvData* rdata = new RecvData(pData, wSize);
        rdata->setdataType(Send_Data);
        recvdatamutex.lock();
        m_recvdataQueue.pushBack(rdata);
        recvdatamutex.unlock();
        rdata->release();
        return false;
    }
    
    this->mappedBuffer(pData, wSize);
    int count = m_pSocket->Send(pData, wSize);
    if(count == SOCKET_ERROR)
    {
        this->Disconnettologin("网络异常，请重新登录");
    }
    
    return true;
}

//隐射数据
bool CTCPSocket::mappedBuffer(void* pData, WORD wDataSize)
{
    return true;
}

//隐射数据
bool CTCPSocket::unMappedBuffer(void* pData, WORD wDataSize)
{
    return true;
}

//多线程创建
bool CTCPSocket::threadCreate()
{
#ifdef WIN32
#ifdef PTW32_STATIC_LIB
    pthread_win32_process_attach_np();
#endif
#endif
    
    pthread_attr_t attr;
    
    pthread_attr_init(&attr);
    
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    
    int code = pthread_create(&m_hThread, 0, threadSocketRecv, this);
    
    if (code !=0)
    {
        CCLOG("fail to create thread");
    }
    
    pthread_detach(m_hThread);
    
    
    return true;
}

//detach线程
void CTCPSocket::threadClosed()
{
    m_bConnect=false;
    
#ifdef WIN32
#ifdef PTW32_STATIC_LIB
    pthread_win32_process_detach_np();
#endif
#endif
}


bool CTCPSocket::getConnect()
{
    return this->m_bConnect;
}
