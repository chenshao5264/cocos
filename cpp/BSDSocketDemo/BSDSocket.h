//
//  BSDSocket.hpp
//  HelloWorld_3_12
//
//  Created by 辰少 on 16/10/12.
//
//

#ifndef BSDSocket_hpp
#define BSDSocket_hpp

#ifdef WIN32
    #include <winsock2.h>
    typedef int             socklen_t;
#else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <netdb.h>
    #include <fcntl.h>
    #include <unistd.h>
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <arpa/inet.h>
    typedef int             SOCKET;

    //#pragma region define win32 const variable in linux
    #define INVALID_SOCKET  -1
    #define SOCKET_ERROR    -1
    //#pragma endregion
#endif


class CBSDSocket
{
public:
    CBSDSocket(SOCKET sock = INVALID_SOCKET);
    ~CBSDSocket();
    
    // Create socket object for snd/recv data
    bool Create(int af, int type, int protocol = 0);
    
    // Connect socket
    bool Connect(const char* ip, unsigned short port);
    
    // #region server
    // Bind socket
    bool Bind(unsigned short port);
    
    // Listen socket
    bool Listen(int backlog = 5);
    
    // Accept socket
    bool Accept(CBSDSocket& s, char* fromip = NULL);
    
    // #endregion
    int Select();
    
    // Send socket
    int Send(const char* buf, int len, int flags = 0);
    
    // Recv socket
    int Recv(char* buf, int len, int flags = 0);
    
    // Close socket
    int Close();
    
    // Get errno
    int GetError();
    
    // #pragma region just for win32
    // Init winsock DLL
    static int Init();
    // Clean winsock DLL
    static int Clean();
    // #pragma endregion
    
    // Domain parse
    static bool DnsParse(const char* domain, char* ip);
    
    CBSDSocket& operator = (SOCKET s);
    
    operator SOCKET();
protected:
    SOCKET m_sock;
};

#endif /* BSDSocket_hpp */
