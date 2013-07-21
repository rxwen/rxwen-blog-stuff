LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := libsysproperty
LOCAL_C_INCLUDES := 

LOCAL_LDLIBS    := -llog
LOCAL_CFLAGS := -DDEBUG -g

LOCAL_SRC_FILES := \
	sys_property.c

include $(BUILD_SHARED_LIBRARY)
