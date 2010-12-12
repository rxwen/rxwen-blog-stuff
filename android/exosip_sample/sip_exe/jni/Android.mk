LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
		sipexe.c

LOCAL_CFLAGS +=	-DOSIP_MT -DENABLE_TRACE

LOCAL_SHARED_LIBRARIES := \
        libosip libexosip

LOCAL_LDLIBS += -llog

LOCAL_PRELINK_MODULE := false

LOCAL_MODULE:= sipexe

include $(BUILD_EXECUTABLE)
$(call import-module,libosip)
$(call import-module,libexosip)
