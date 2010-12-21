LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
		readproperty.c


LOCAL_PRELINK_MODULE := false

LOCAL_MODULE:= readproperty

include $(BUILD_EXECUTABLE)
