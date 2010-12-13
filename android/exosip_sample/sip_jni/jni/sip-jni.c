#include <string.h>
#include <jni.h>

#include	<unistd.h>
#include	<android/log.h>
#include	<netinet/in.h>
#include    <eXosip2/eXosip.h>

const char* const LOG_TAG = "SIP_JNI";

static void android_trace_func(char *fi, int li, osip_trace_level_t level, char *chfr, va_list ap)
{
    __android_log_vprint(ANDROID_LOG_VERBOSE, LOG_TAG, chfr, ap);
}

void Java_com_rmd_sipjni_SipJni_startSipService(JNIEnv* env, jobject thiz )
{
    jclass cls = (*env)->FindClass(env, "com/rmd/sipjni/SipJni");
    jmethodID mid = (*env)->GetMethodID(env, cls, "onIncomingCall", "(Ljava/lang/String;)Z");
    __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, "%s:%d mid is %d, thiz is %p", __FILE__, __LINE__, mid, thiz);
    jstring js = (*env)->NewStringUTF(env, "incoming call");
    __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, "%s:%d", __FILE__, __LINE__);
    jboolean bl = (*env)->CallBooleanMethod(env, thiz, js);
    __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, "%s:%d", __FILE__, __LINE__);
    int i, port = 5060;
    osip_trace_initialize_func(END_TRACE_LEVEL, &android_trace_func);
    i=eXosip_init();
    if (i!=0)
        return;
    i = eXosip_listen_addr (IPPROTO_UDP, NULL, port, AF_INET, 0);
    if (i!=0)
    {
        eXosip_quit();
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "%s", "could not initialize transport layer\n");
        return;
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
            __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, "%s", "incomingCall returns\n");
        }
    }

    return;
}
