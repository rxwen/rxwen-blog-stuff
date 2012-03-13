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
//#include	"Discovery.h"
//#include	"ActionRequest.h"
//#include	"ActionComplete.h"
//#include	"StateVarRequest.h"
//#include	"StateVarComplete.h"
//#include	"SubscriptionRequest.h"
//#include	"Event.h"
//#include	"EventSubscribe.h"
//#include	"poison.h"

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

void SampleUtil_PrintEventType(Upnp_EventType S)
{
	switch (S) {
	/* Discovery */
	case UPNP_DISCOVERY_ADVERTISEMENT_ALIVE:
		LOGI("UPNP_DISCOVERY_ADVERTISEMENT_ALIVE\n");
		break;
	case UPNP_DISCOVERY_ADVERTISEMENT_BYEBYE:
		LOGI("UPNP_DISCOVERY_ADVERTISEMENT_BYEBYE\n");
		break;
	case UPNP_DISCOVERY_SEARCH_RESULT:
		LOGI( "UPNP_DISCOVERY_SEARCH_RESULT\n");
		break;
	case UPNP_DISCOVERY_SEARCH_TIMEOUT:
		LOGI( "UPNP_DISCOVERY_SEARCH_TIMEOUT\n");
		break;
	/* SOAP */
	case UPNP_CONTROL_ACTION_REQUEST:
		LOGI("UPNP_CONTROL_ACTION_REQUEST\n");
		break;
	case UPNP_CONTROL_ACTION_COMPLETE:
		LOGI("UPNP_CONTROL_ACTION_COMPLETE\n");
		break;
	case UPNP_CONTROL_GET_VAR_REQUEST:
		LOGI("UPNP_CONTROL_GET_VAR_REQUEST\n");
		break;
	case UPNP_CONTROL_GET_VAR_COMPLETE:
		LOGI("UPNP_CONTROL_GET_VAR_COMPLETE\n");
		break;
	/* GENA */
	case UPNP_EVENT_SUBSCRIPTION_REQUEST:
		LOGI("UPNP_EVENT_SUBSCRIPTION_REQUEST\n");
		break;
	case UPNP_EVENT_RECEIVED:
		LOGI("UPNP_EVENT_RECEIVED\n");
		break;
	case UPNP_EVENT_RENEWAL_COMPLETE:
		LOGI("UPNP_EVENT_RENEWAL_COMPLETE\n");
		break;
	case UPNP_EVENT_SUBSCRIBE_COMPLETE:
		LOGI("UPNP_EVENT_SUBSCRIBE_COMPLETE\n");
		break;
	case UPNP_EVENT_UNSUBSCRIBE_COMPLETE:
		LOGI("UPNP_EVENT_UNSUBSCRIBE_COMPLETE\n");
		break;
	case UPNP_EVENT_AUTORENEWAL_FAILED:
		LOGI("UPNP_EVENT_AUTORENEWAL_FAILED\n");
		break;
	case UPNP_EVENT_SUBSCRIPTION_EXPIRED:
		LOGI("UPNP_EVENT_SUBSCRIPTION_EXPIRED\n");
		break;
	}
}

int TvCtrlPointCallbackEventHandler(Upnp_EventType EventType, const void *Event, void *Cookie)
{
	int errCode = 0;

    LOGI("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ TvCtrlPointCallbackEventHandler event type: %d\n",
		     EventType);
    SampleUtil_PrintEventType(EventType);
	switch ( EventType ) {
	/* SSDP Stuff */
	case UPNP_DISCOVERY_ADVERTISEMENT_ALIVE:
	case UPNP_DISCOVERY_SEARCH_RESULT: 
        {
//		const UpnpDiscovery *d_event = (UpnpDiscovery *)Event;
//		IXML_Document *DescDoc = NULL;
//		const char *location = NULL;
//		int errCode = UpnpDiscovery_get_ErrCode(d_event);
//
//		if (errCode != UPNP_E_SUCCESS) {
//			SampleUtil_Print(
//				"Error in Discovery Callback -- %d\n", errCode);
//		}
//
//		location = UpnpString_get_String(UpnpDiscovery_get_Location(d_event));
//		errCode = UpnpDownloadXmlDoc(location, &DescDoc);
//		if (errCode != UPNP_E_SUCCESS) {
//			SampleUtil_Print(
//				"Error obtaining device description from %s -- error = %d\n",
//				location, errCode);
//		} else {
//			TvCtrlPointAddDevice(
//				DescDoc, location, UpnpDiscovery_get_Expires(d_event));
//		}
//		if (DescDoc) {
//			ixmlDocument_free(DescDoc);
//		}
//		TvCtrlPointPrintList();
		break;
	}
	case UPNP_DISCOVERY_SEARCH_TIMEOUT:
		/* Nothing to do here... */
		break;
	case UPNP_DISCOVERY_ADVERTISEMENT_BYEBYE: 
//        {
//		UpnpDiscovery *d_event = (UpnpDiscovery *)Event;
//		int errCode = UpnpDiscovery_get_ErrCode(d_event);
//		const char *deviceId = UpnpString_get_String(
//		UpnpDiscovery_get_DeviceID(d_event));
//
//		if (errCode != UPNP_E_SUCCESS) {
//			SampleUtil_Print(
//				"Error in Discovery ByeBye Callback -- %d\n", errCode);
//		}
//		SampleUtil_Print("Received ByeBye for Device: %s\n", deviceId);
//		TvCtrlPointRemoveDevice(deviceId);
//		SampleUtil_Print("After byebye:\n");
//		TvCtrlPointPrintList();
//		break;
//	}
	/* SOAP Stuff */
	case UPNP_CONTROL_ACTION_COMPLETE: 
//        {
//		UpnpActionComplete *a_event = (UpnpActionComplete *)Event;
//		int errCode = UpnpActionComplete_get_ErrCode(a_event);
//		if (errCode != UPNP_E_SUCCESS) {
//			SampleUtil_Print("Error in  Action Complete Callback -- %d\n",
//				errCode);
//		}
//		/* No need for any processing here, just print out results.
//		 * Service state table updates are handled by events. */
//		break;
//	}
//	case UPNP_CONTROL_GET_VAR_COMPLETE: {
//		UpnpStateVarComplete *sv_event = (UpnpStateVarComplete *)Event;
//		int errCode = UpnpStateVarComplete_get_ErrCode(sv_event);
//		if (errCode != UPNP_E_SUCCESS) {
//			SampleUtil_Print(
//				"Error in Get Var Complete Callback -- %d\n", errCode);
//		} else {
//			TvCtrlPointHandleGetVar(
//				UpnpString_get_String(UpnpStateVarComplete_get_CtrlUrl(sv_event)),
//				UpnpString_get_String(UpnpStateVarComplete_get_StateVarName(sv_event)),
//				UpnpStateVarComplete_get_CurrentVal(sv_event));
//		}
//		break;
//	}
	/* GENA Stuff */
	case UPNP_EVENT_RECEIVED: 
//        {
//		UpnpEvent *e_event = (UpnpEvent *)Event;
//		TvCtrlPointHandleEvent(
//			UpnpEvent_get_SID_cstr(e_event),
//			UpnpEvent_get_EventKey(e_event),
//			UpnpEvent_get_ChangedVariables(e_event));
//		break;
//	}
	case UPNP_EVENT_SUBSCRIBE_COMPLETE:
	case UPNP_EVENT_UNSUBSCRIBE_COMPLETE:
	case UPNP_EVENT_RENEWAL_COMPLETE: 
//        {
//		UpnpEventSubscribe *es_event = (UpnpEventSubscribe *)Event;
//
//		errCode = UpnpEventSubscribe_get_ErrCode(es_event);
//		if (errCode != UPNP_E_SUCCESS) {
//			SampleUtil_Print(
//				"Error in Event Subscribe Callback -- %d\n", errCode);
//		} else {
//			TvCtrlPointHandleSubscribeUpdate(
//				UpnpString_get_String(UpnpEventSubscribe_get_PublisherUrl(es_event)),
//				UpnpString_get_String(UpnpEventSubscribe_get_SID(es_event)),
//				UpnpEventSubscribe_get_TimeOut(es_event));
//		}
//		break;
//	}
	case UPNP_EVENT_AUTORENEWAL_FAILED:
	case UPNP_EVENT_SUBSCRIPTION_EXPIRED: 
//        {
//		UpnpEventSubscribe *es_event = (UpnpEventSubscribe *)Event;
//		int TimeOut = default_timeout;
//		Upnp_SID newSID;
//
//		errCode = UpnpSubscribe(
//			ctrlpt_handle,
//			UpnpString_get_String(UpnpEventSubscribe_get_PublisherUrl(es_event)),
//			&TimeOut,
//			newSID);
//		if (errCode == UPNP_E_SUCCESS) {
//			SampleUtil_Print("Subscribed to EventURL with SID=%s\n", newSID);
//			TvCtrlPointHandleSubscribeUpdate(
//				UpnpString_get_String(UpnpEventSubscribe_get_PublisherUrl(es_event)),
//				newSID,
//				TimeOut);
//		} else {
//			SampleUtil_Print("Error Subscribing to EventURL -- %d\n", errCode);
//		}
//		break;
//	}
	/* ignore these cases, since this is not a device */
	case UPNP_EVENT_SUBSCRIPTION_REQUEST:
	case UPNP_CONTROL_GET_VAR_REQUEST:
	case UPNP_CONTROL_ACTION_REQUEST:
		break;
	}

	return 0;
}

int Java_com_rmd_tpupnp_Main_startUpnp(JNIEnv* env, jobject thiz)
{
    const char* ip_address = "0.0.0.0";
    const int port = 7080;
    int rc = UpnpInit(ip_address, port);
    LOGI("UpnpInit returns %s %d", "hello", rc);
    if(UPNP_E_SUCCESS != rc)
        return 1;

    UpnpDevice_Handle device_handle = -1;
//    rc = UpnpRegisterRootDevice("http://pupnp.git.sourceforge.net/git/gitweb.cgi?p=pupnp/pupnp;a=blob_plain;f=upnp/sample/web/tvdevicedesc.xml;hb=HEAD",
//            TvDeviceCallbackEventHandler, &device_handle, &device_handle);
    rc = UpnpRegisterClient(TvCtrlPointCallbackEventHandler, &device_handle, &device_handle);
    if(UPNP_E_SUCCESS != rc)
        return 1;
    rc = UpnpSearchAsync(device_handle, 5, "urn:schemas-upnp-org:device:tvdevice:1", NULL);
	if (UPNP_E_SUCCESS != rc) {
		return 1;
	}


//    rc = UpnpSendAdvertisement(device_handle, 100 /* seconds */);
    if(UPNP_E_SUCCESS != rc)
        return 1;
    else
        return 0;
}
