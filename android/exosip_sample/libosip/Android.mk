LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
		src/osipparser2/osip_accept.c \
		src/osipparser2/osip_proxy_authenticate.c \
		src/osipparser2/osip_parser_cfg.c \
		src/osipparser2/osip_mime_version.c \
		src/osipparser2/osip_uri.c \
		src/osipparser2/osip_call_id.c \
		src/osipparser2/osip_contact.c \
		src/osipparser2/osip_header.c \
		src/osipparser2/osip_list.c \
		src/osipparser2/osip_authentication_info.c \
		src/osipparser2/osip_cseq.c \
		src/osipparser2/osip_message.c \
		src/osipparser2/osip_record_route.c \
		src/osipparser2/osip_authorization.c \
		src/osipparser2/sdp_accessor.c \
		src/osipparser2/osip_accept_language.c \
		src/osipparser2/osip_via.c \
		src/osipparser2/osip_allow.c \
		src/osipparser2/osip_call_info.c \
		src/osipparser2/osip_proxy_authentication_info.c \
		src/osipparser2/osip_proxy_authorization.c \
		src/osipparser2/sdp_message.c \
		src/osipparser2/osip_accept_encoding.c \
		src/osipparser2/osip_content_encoding.c \
		src/osipparser2/osip_to.c \
		src/osipparser2/osip_content_disposition.c \
		src/osipparser2/osip_message_to_str.c \
		src/osipparser2/osip_www_authenticate.c \
		src/osipparser2/osip_error_info.c \
		src/osipparser2/osip_body.c \
		src/osipparser2/osip_content_length.c \
		src/osipparser2/osip_from.c \
		src/osipparser2/osip_alert_info.c \
		src/osipparser2/osip_message_parse.c \
		src/osipparser2/osip_content_type.c \
		src/osipparser2/osip_port.c \
		src/osipparser2/osip_md5c.c \
		src/osipparser2/osip_route.c \
		src/osip2/osip_transaction.c \
		src/osip2/osip_dialog.c \
		src/osip2/osip_event.c \
		src/osip2/nict_fsm.c \
		src/osip2/port_thread.c \
		src/osip2/nict.c \
		src/osip2/nist.c \
		src/osip2/port_sema.c \
		src/osip2/ict_fsm.c \
		src/osip2/ict.c \
		src/osip2/port_fifo.c \
		src/osip2/ist_fsm.c \
		src/osip2/ist.c \
		src/osip2/osip_time.c \
		src/osip2/port_condv.c \
		src/osip2/fsm_misc.c \
		src/osip2/osip.c \
		src/osip2/nist_fsm.c

LOCAL_CFLAGS += -DHAVE_FCNTL_H \
				-DHAVE_SYS_TIME_H \
				-DHAVE_STRUCT_TIMEVAL \
				-DHAVE_SYS_SELECT_H \
				-DHAVE_PTHREAD \
				-DHAVE_SEMAPHORE_H \
				-DENABLE_TRACE \
				-DOSIP_MT

LOCAL_C_INCLUDES:= $(LOCAL_PATH)/include $(LOCAL_PATH)/src 
LOCAL_EXPORT_C_INCLUDES:=$(LOCAL_C_INCLUDES)

LOCAL_PRELINK_MODULE := false
#LOCAL_LDLIBS += -lpthread -ldl

LOCAL_MODULE:= libosip

include $(BUILD_SHARED_LIBRARY)
