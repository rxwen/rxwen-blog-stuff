LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := sip-jni
LOCAL_SRC_FILES := sip-jni.c

LOCAL_CFLAGS +=	-DOSIP_MT -DENABLE_TRACE

LOCAL_SHARED_LIBRARIES := \
        libosip libexosip

LOCAL_LDLIBS += -llog

include $(BUILD_SHARED_LIBRARY)
$(call import-module,libosip)
$(call import-module,libexosip)
