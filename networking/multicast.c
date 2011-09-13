#ifdef WIN32

#include <stdio.h>
#include <tchar.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <time.h>
#pragma comment(lib, "Ws2_32.lib")

#else

#include <strings.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <time.h>
#include <stdio.h>

#endif

#define PORT 6789
#define GROUPIP "239.0.1.2"

int main(int argc, char* argv[])
{	
	struct sockaddr_in addr;
	int addrlen, sock, count;
	struct ip_mreq mreq;
	char message[50];

#ifdef WIN32
	WSADATA wsaData;
	int iResult;

	// Initialize Winsock
	iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
	if (iResult != 0) {
		printf("WSAStartup failed: %d\n", iResult);
		return 1;
	}
#endif

	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		perror("failed to create socket");
		exit(1);
	}
#ifdef WIN32
	ZeroMemory((char *)&addr, sizeof(addr));
#else
	bzero((char *)&addr, sizeof(addr));
#endif
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(PORT);
	addrlen = sizeof(addr);

	if (argc > 1) {
		addr.sin_addr.s_addr = inet_addr(GROUPIP);
		while (1) {
			time_t t = time(0);
			sprintf(message, "time is %-24.24s", ctime(&t));
			printf("sending: %s\n", message);
			count = sendto(sock, message, sizeof(message), 0,
				(struct sockaddr *) &addr, addrlen);
			if (count < 0) {
				perror("failed to sendto");
				exit(1);
			}
#ifdef WIN32
			Sleep(2000);
#else			
            sleep(2);
#endif
		}
	} else {
		const int on = 1;
		if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
			(char*)&on, sizeof(on)) < 0) {
				perror("failed to setsockopt SO_REUSEADDR");
				exit(1);
		}
		if (bind(sock, (struct sockaddr *) &addr, sizeof(addr)) < 0) {        
			perror("failed to bind");
			exit(1);
		}    
		mreq.imr_multiaddr.s_addr = inet_addr(GROUPIP);         
		mreq.imr_interface.s_addr = htonl(INADDR_ANY);         
		if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP,
			(char*)&mreq, sizeof(mreq)) < 0) {
				perror("failed to setsockopt mreq");
				exit(1);
		}         
		while (1) {
			count = recvfrom(sock, message, sizeof(message), 0, 
				(struct sockaddr *) &addr, &addrlen);
			if (count < 0) {
				perror("failed to recvfrom");
				exit(1);
			} else if (count == 0) {
				break;
			}
			printf("%s: message = \"%s\"\n", inet_ntoa(addr.sin_addr), message);
		}
	}

	return 0;
}