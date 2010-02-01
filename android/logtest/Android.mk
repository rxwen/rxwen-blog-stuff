LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
	logtest.cpp

LOCAL_SHARED_LIBRARIES := \
	libcutils

LOCAL_MODULE:= logtest 

include $(BUILD_EXECUTABLE)
