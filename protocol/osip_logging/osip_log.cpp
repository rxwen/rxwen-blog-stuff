#define ENABLE_TRACE
#include "osip2/osip.h"
#include <stdio.h>

void printf_trace_func (char *fi, int li, osip_trace_level_t level, char *chfr, va_list ap)
{
    const char* desc = "       ";
    switch(level)
    {
    case OSIP_FATAL:
        desc = " FATAL ";
        break;
    case OSIP_BUG:
        desc = "  BUG  ";
        break;
    case OSIP_ERROR:
        desc = " ERROR ";
        break;
    case OSIP_WARNING:
        desc = "WARNING";
        break;
    case OSIP_INFO1:
        desc = " INFO1 ";
        break;
    case OSIP_INFO2:
        desc = " INFO2 ";
        break;
    case OSIP_INFO3:
        desc = " INFO3 ";
        break;
    case OSIP_INFO4:
        desc = " INFO4 ";
        break;
    default:
        desc = "       ";
    }
    
    printf ("|%s| <%s: %i> | ", desc, fi, li);
    printf(chfr, ap);
    printf ("\n");
}


int main(int argc, _TCHAR* argv[])
{
    // use plain file as logging storage
    // FILE* f = fopen("c:\\1.txt", "w");
    // TRACE_INITIALIZE(END_TRACE_LEVEL, f);

    // use custom function
    osip_trace_initialize_func(END_TRACE_LEVEL, &printf_trace_func);

    // write log message
    OSIP_TRACE (osip_trace(__FILE__, __LINE__, static_cast<osip_trace_level_t>(OSIP_INFO1), NULL, "osip_trace module initialized!"));
   
    // trun log message of OSIP_INFO1 level off
    TRACE_DISABLE_LEVEL(OSIP_INFO1);
    
    OSIP_TRACE (osip_trace(__FILE__, __LINE__, static_cast<osip_trace_level_t>(OSIP_INFO1), NULL, "osip_trace module initialized!"));
	return 0;
}
