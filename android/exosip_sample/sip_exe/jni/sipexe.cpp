// =====================================================================================
// 
//       Filename:  sipexe.cpp
// 
//    Description:  
// 
//        Version:  1.0
//        Created:  12/10/2010 07:38:57 PM
//       Revision:  none
//       Compiler:  g++
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================

#include	<unistd.h>
#include	<android/log.h>
#include	<netinet/in.h>
#include    <eXosip2/eXosip.h>
#include    <iostream>
#include	<complex>

const char* const LOG_TAG = "SIP_EXE";

static void android_trace_func(char *fi, int li, osip_trace_level_t level, char *chfr, va_list ap)
{
    __android_log_vprint(ANDROID_LOG_VERBOSE, LOG_TAG, chfr, ap);
}

int main ( int argc, char *argv[] )
{
    int i, port = 5060;
    osip_trace_initialize_func(END_TRACE_LEVEL, &android_trace_func);
    i=eXosip_init();
    if (i!=0)
        return -1;
    i = eXosip_listen_addr (IPPROTO_UDP, NULL, port, AF_INET, 0);
    if (i!=0)
    {
        eXosip_quit();
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "%s", "could not initialize transport layer\n");
        return -1;
    }

    eXosip_event_t *je;
    for (;;)
    {
        je = eXosip_event_wait (0, 24*60*60*1000);
        eXosip_lock();
        eXosip_automatic_action ();
        eXosip_unlock();
        if (je == NULL)
            break;
        if (je->type == EXOSIP_CALL_INVITE)
        {
            __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, "%s", "incoming call\n");
            std::cout << "incoming call" << std::endl;
        }
    }

    return 0;
}				// ----------  end of function main  ----------
