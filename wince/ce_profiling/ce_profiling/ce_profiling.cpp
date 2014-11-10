// ce_profiling.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

void bar()
{
    Sleep(1000);
    printf("bar\n");
}

void foo()
{
    bar();
    Sleep(3000);
    printf("foo\n");
}

int _tmain(int argc, _TCHAR* argv[])
{
    foo();
	return 0;
}

