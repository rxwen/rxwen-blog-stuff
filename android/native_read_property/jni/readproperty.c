// =====================================================================================
// 
//       Filename:  rmd.c
// 
//    Description:  
// 
//        Version:  1.0
//        Created:  12/21/2010 08:55:57 PM
//       Revision:  none
//       Compiler:  g++
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================


#include	<sys/system_properties.h>

int main ( int argc, char *argv[] )
{
    char value[PROP_VALUE_MAX];
    const char* name = "media.stagefright.enable-http";
    __system_property_get(name, value);
    printf("%s: %s\n", name, value);
    return 0;
}				// ----------  end of function main  ----------
