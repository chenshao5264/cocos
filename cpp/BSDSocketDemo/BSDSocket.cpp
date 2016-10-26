//
//  BSDSocket.cpp
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/12.
//
//

#include <stdio.h>
#include "BSDSocket.h"

#ifdef WIN32
    #pragma comment(lib, "wsock32")
#endif

CBSDSocket::CBSDSocket(SOCKET sock)
{
    m_sock = sock;
}

CBSDSocket::~CBSDSocket()
{
}

int CBSDSocket::Init()
{
#ifdef WIN32
    /*
     http://msdn.microsoft.com/zh-cn/vstudio/ms741563(en-us,VS.85).aspx
     
     typedef struct WSAData {
     WORD wVersion;								//winsock version
     WORD wHighVersion;							//The highest version of the Windows Sockets specification that the Ws2_32.dll can support
     char szDescription[WSADESCRIPTION_LEN+1];
     char szSystemStatus[WSASYSSTATUS_LEN+1];
     unsigned short iMaxSockets;
     unsigned short iMaxUdpDg;
     char FAR * lpVendorInfo;
     }WSADATA, *LPWSADATA;
     */
    WSADATA wsaData;
    //#define MAKEWORD(a,b) ((WORD) (((BYTE) (a)) | ((WORD) ((BYTE) (b))) << 8))
    WORD version = MAKEWORD(2, 0);
    int ret = WSAStartup(version, &wsaData); //win sock start up
    if (ret) {
        //		cerr << "Initilize winsock error !" << endl;
        return -1;
    }
#endif
    
    return 0;
}

//this is just for windows
int CBSDSocket::Clean()
{
#ifdef WIN32
    return (WSACleanup());
#endif
    return 0;
}

CBSDSocket& CBSDSocket::operator =(SOCKET s)
{
    m_sock = s;
    return (*this);
}

CBSDSocket::operator SOCKET()
{
    return m_sock;
}

//create a socket object win/lin is the same
// af:
bool CBSDSocket::Create(int af, int type, int protocol)
{
    m_sock = socket(af, type, protocol);
    if (m_sock == INVALID_SOCKET) {
        return false;
    }
    return true;
}

bool CBSDSocket::Connect(const char* ip, unsigned short port)
{
    //连接ip
    struct sockaddr_in svraddr;
    svraddr.sin_family = AF_INET;
    svraddr.sin_addr.s_addr = inet_addr(ip);
    svraddr.sin_port = htons(port);
    int ret = connect(m_sock, (struct sockaddr*) &svraddr, sizeof(svraddr));
    if (ret == SOCKET_ERROR)
    {
        return false;
    }
    return true;
}

bool CBSDSocket::Bind(unsigned short port)
{
    struct sockaddr_in svraddr;
    svraddr.sin_family = AF_INET;
    svraddr.sin_addr.s_addr = INADDR_ANY;
    svraddr.sin_port = htons(port);
    
    int opt =  1;
    if ( setsockopt(m_sock, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt)) < 0 )
        return false;
    
    int ret = bind(m_sock, (struct sockaddr*)&svraddr, sizeof(svraddr));
    if ( ret == SOCKET_ERROR ) {
        return false;
    }
    return true;
}

//for server
bool CBSDSocket::Listen(int backlog)
{
    int ret = listen(m_sock, backlog);
    if ( ret == SOCKET_ERROR ) {
        return false;
    }
    return true;
}

bool CBSDSocket::Accept(CBSDSocket& s, char* fromip)
{
    struct sockaddr_in cliaddr;
    socklen_t addrlen = sizeof(cliaddr);
    SOCKET sock = accept(m_sock, (struct sockaddr*)&cliaddr, &addrlen);
    if ( sock == SOCKET_ERROR )
    {
        return false;
    }
    
    s = sock;
    if ( fromip != NULL )
        sprintf(fromip, "%s", inet_ntoa(cliaddr.sin_addr));
    
    return true;
}

int CBSDSocket::Send(const char* buf, int len, int flags)
{
    int bytes;
    int count = 0;
    
    while( count < len )
    {
        bytes = (int)send(m_sock, buf + count, len - count, flags);
        if ( bytes == -1 || bytes == 0 )
            return -1;
        
        count += bytes;
    } 
    
    return count;
}

int CBSDSocket::Recv(char* buf, int len, int flags)
{
    return (int)(recv(m_sock, buf, len, flags));
}

int CBSDSocket::Close() {
#ifdef WIN32
    return (closesocket(m_sock));
#else
    shutdown(m_sock, 2);
    return (close(m_sock));
#endif
}

int CBSDSocket::GetError()
{
#ifdef WIN32
    return (WSAGetLastError());
#else
    return (errno);
#endif
}

bool CBSDSocket::DnsParse(const char* domain, char* ip)
{
    struct hostent* p;
    if ((p = gethostbyname(domain)) == NULL)
        return false;
    
    sprintf(ip, "%u.%u.%u.%u", (unsigned char) p->h_addr_list[0][0],
            (unsigned char) p->h_addr_list[0][1],
            (unsigned char) p->h_addr_list[0][2],
            (unsigned char) p->h_addr_list[0][3]);
    
    return true;
}
