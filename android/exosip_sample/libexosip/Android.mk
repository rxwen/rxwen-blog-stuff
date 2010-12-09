LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
		tools/sip_reg.c \
		src/eXtl.c \
		src/eXsubscription_api.c \
		src/eXregister_api.c \
		src/jevents.c \
		src/jcallback.c \
		src/eXtl_tcp.c \
		src/rijndael.c \
		src/jreg.c \
		src/sdp_offans.c \
		src/eXconf.c \
		src/jauth.c \
		src/udp.c \
		src/eXcall_api.c \
		src/eXtl_tls.c \
		src/jdialog.c \
		src/eXtransport.c \
		src/eXosip.c \
		src/jrequest.c \
		src/jsubscribe.c \
		src/eXtl_dtls.c \
		src/jcall.c \
		src/misc.c \
		src/milenage.c \
		src/jresponse.c \
		src/eXmessage_api.c \
		src/eXtl_udp.c \
		src/eXoptions_api.c \
		src/eXinsubscription_api.c \
		src/eXutils.c \
		src/eXrefer_api.c \
		src/jpipe.c \
		src/jpublish.c \
		src/eXpublish_api.c \
		src/jnotify.c \
		src/inet_ntop.c

LOCAL_CFLAGS += -DHAVE_TIME_H \
				-DHAVE_SYS_SELECT_H \
				-DOSIP_MT

LOCAL_C_INCLUDES:= $(LOCAL_PATH)/include $(LOCAL_PATH)/src \
	$(LOCAL_PATH)/../libosip/include

LOCAL_SHARED_LIBRARIES := \
        libosip 

#LOCAL_LDLIBS += -lpthread -ldl

LOCAL_PRELINK_MODULE := false

LOCAL_MODULE:= libexosip

include $(BUILD_SHARED_LIBRARY)
$(call import-module,libosip)
