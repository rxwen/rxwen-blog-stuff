// =====================================================================================
// 
//       Filename:  simplest_tcp_server_on_new_thread.cpp
// 
//    Description:  
// 
//        Version:  1.0
//        Created:  10/27/2010 09:39:56 AM
//       Revision:  none
//       Compiler:  g++
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================


#include	<string.h>
#include	<iostream>
#include	<netinet/in.h>
#include	<sys/socket.h>
#include	<pthread.h>

using namespace std;

static void* proc(void* para)
{
    int sock = *((int*)para);
    if(0 > listen(sock, 1000))
        cout << "error listen" << endl;
    while(1)
    {
        accept(sock, NULL, NULL);
        cout << "accept " << endl;
    }
    return NULL;
}		// -----  end of function proc  -----

int main ( int argc, char *argv[] )
{
    int sock = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in addr;

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(8989);

    if(0 > bind(sock, (struct sockaddr*)&addr, sizeof(addr)))
    {
        cout << "error bind" << endl;
        return 1;
    }
    pthread_t th;
    pthread_create(&th, NULL, proc, &sock);
    while(1)
    {
        continue;
    }

    return 0;
}				// ----------  end of function main  ----------
