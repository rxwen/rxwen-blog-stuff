// =====================================================================================
// 
//       Filename:  logtest.cpp
// 
//    Description:  
// 
//        Version:  1.0
//        Created:  02/01/2010 02:22:56 PM
//       Revision:  none
//       Compiler:  g++
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================


#include	"cutils/log.h"

int main ( int argc, char *argv[] )
{
    LOGE("log ERROR");
    LOGW("log WARN");
    LOGD("log DEBUG");
    LOGI("log INFORMATION");
    LOGV("log VERBOSE");
    return 0;
}				// ----------  end of function main  ----------
