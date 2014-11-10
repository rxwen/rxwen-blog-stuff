#include "stdafx.h"

extern "C" 
{
    void _CAP_Enter_Function(void *p) 
    {
        printf("Enter function   (at address %p) at %d\n", p, GetTickCount());
    }
    void _CAP_Exit_Function(void *p) 
    {
        printf("Leaving function (at address %p) at %d\n", p, GetTickCount());
    }
}
