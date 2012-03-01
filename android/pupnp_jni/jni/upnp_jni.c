// =====================================================================================
// 
//       Filename:  upnp_jni.c
// 
//    Description:  
// 
//        Version:  1.0
//        Created:  02/25/2012 03:03:51 PM
//       Revision:  none
//       Compiler:  g++
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================


#include	<jni.h>
#include	<android/log.h>
#include	"upnp.h"

#define  LOG_TAG    "libtupnp"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)

int TvDeviceCallbackEventHandler(Upnp_EventType EventType, const void *Event, void *Cookie)
{
	switch (EventType) {
	case UPNP_EVENT_SUBSCRIPTION_REQUEST:
	case UPNP_CONTROL_GET_VAR_REQUEST:
	case UPNP_CONTROL_ACTION_REQUEST:
	case UPNP_DISCOVERY_ADVERTISEMENT_ALIVE:
	case UPNP_DISCOVERY_SEARCH_RESULT:
	case UPNP_DISCOVERY_SEARCH_TIMEOUT:
	case UPNP_DISCOVERY_ADVERTISEMENT_BYEBYE:
	case UPNP_CONTROL_ACTION_COMPLETE:
	case UPNP_CONTROL_GET_VAR_COMPLETE:
	case UPNP_EVENT_RECEIVED:
	case UPNP_EVENT_RENEWAL_COMPLETE:
	case UPNP_EVENT_SUBSCRIBE_COMPLETE:
	case UPNP_EVENT_UNSUBSCRIBE_COMPLETE:
		break;
	default:
	    LOGI("Error in TvDeviceCallbackEventHandler: unknown event type %d\n",
		     EventType);
	}
	return 0;
}

int Java_com_rmd_tpupnp_Main_startUpnp(JNIEnv* env, jobject thiz)
{
    const char* ip_address = "127.0.0.1";
    const int port = 7080;
    int rc = UpnpInit(ip_address, port);
    LOGI("UpnpInit returns %s %d", "hello", rc);
    if(UPNP_E_SUCCESS != rc)
        return 1;

    UpnpDevice_Handle device_handle = -1;
    rc = UpnpRegisterRootDevice("http://pupnp.git.sourceforge.net/git/gitweb.cgi?p=pupnp/pupnp;a=blob_plain;f=upnp/sample/web/tvdevicedesc.xml;hb=HEAD",
            TvDeviceCallbackEventHandler, &device_handle, &device_handle);
    if(UPNP_E_SUCCESS != rc)
        return 1;

    rc = UpnpSendAdvertisement(device_handle, 100 /* seconds */);
    if(UPNP_E_SUCCESS != rc)
        return 1;
    else
        return 0;
}
