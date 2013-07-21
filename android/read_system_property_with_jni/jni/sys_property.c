/**
 * Copyright (C) 2013 read_property
 *
 * @author Raymond Wen, rx.wen218@gmail.com
 * @date   2013 Jul 21 15:00:58
 * 
 */


#include	<jni.h>
#include	<android/log.h>
#include	<sys/system_properties.h>
#include    <stdlib.h>

#define  LOG_TAG    "libtupnp"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)

jstring Java_com_rmd_propertySample_MainActivity_getProperty(JNIEnv* env, jobject thiz, jstring property_name) {
    char value[PROP_VALUE_MAX];
    /*const char* name = "net.dns1";*/
    const char* name = (*env)->GetStringUTFChars(env, property_name, NULL);

    __system_property_get(name, value);
    LOGI("__system_property_get: %s: %s", name, value);
    return (*env)->NewStringUTF(env, value);
    /*return 0;*/
}

void Java_com_rmd_propertySample_MainActivity_setProperty(JNIEnv* env, 
        jobject thiz, 
        jstring property_name,
        jstring property_value) {
}
