#include <strings.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <time.h>
#include <stdio.h>

#define PORT 6789
#define GROUPIP "239.0.1.2"

int main(int argc)
{
    struct sockaddr_in addr;
    int addrlen, sock, count;
    struct ip_mreq mreq;
    char message[50];

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("socket");
        exit(1);
    }
    bzero((char *)&addr, sizeof(addr));
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
            sleep(5);
        }
    } else {
        const int on = 1;
        if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
                    &on, sizeof(on)) < 0) {
            perror("failed to setsockopt SO_REUSEADDR");
            exit(1);
        }
        if (bind(sock, (struct sockaddr *) &addr, sizeof(addr)) < 0) {        
            perror("bind");
            exit(1);
        }    
        mreq.imr_multiaddr.s_addr = inet_addr(GROUPIP);         
        mreq.imr_interface.s_addr = htonl(INADDR_ANY);         
        if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP,
                    &mreq, sizeof(mreq)) < 0) {
            perror("failed to setsockopt mreq");
            exit(1);
        }         
        while (1) {
            count = recvfrom(sock, message, sizeof(message), 0, 
                    (struct sockaddr *) &addr, &addrlen);
            if (count < 0) {
                perror("recvfrom");
                exit(1);
            } else if (count == 0) {
                break;
            }
            printf("%s: message = \"%s\"\n", inet_ntoa(addr.sin_addr), message);
        }
    }
}

