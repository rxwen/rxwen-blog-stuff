#!/usr/bin/env python
# -*- coding: utf-8 -*-

##
# @brief a utility convert a email file to its text representation, it will automatically convert base64 encoded content

import sys
import email
import base64

def convert_body_to_str(msg):
    out = ""
    if msg.is_multipart():
        for p in msg.get_payload():
            out += convert_body_to_str(p)
    else:
        if msg.get_content_type().lower().startswith("text"):
            if msg.get("Content-Transfer-encoding") == "base64":
                out += base64.decodestring(msg.get_payload())
            else:
                out += msg.get_payload()
    return out

def main():
    msg = None
    if len(sys.argv) < 2:
        mail = sys.stdin.read()
        msg = email.message_from_string(mail)
    else:
        mail = open(sys.argv[1], "r")
        msg = email.message_from_file(mail)

    out = msg['Subject'] + '\n'
    out += convert_body_to_str(msg)
    print out

if __name__ == "__main__":
    main()
