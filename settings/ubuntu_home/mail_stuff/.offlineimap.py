#!/usr/bin/python

import sys
import gtk
from getpass import getpass
import gnomekeyring as gkey

class Keyring(object):
    def __init__(self, name, server, protocol):
        self._name = name
        self._server = server
        self._protocol = protocol
        self._keyring = gkey.get_default_keyring_sync()

    def has_credentials(self):
        try:
            attrs = {"server": self._server, "protocol": self._protocol}
            items = gkey.find_items_sync(gkey.ITEM_NETWORK_PASSWORD, attrs)
            return len(items) > 0
        except gkey.DeniedError:
            return False

    def get_credentials(self):
        attrs = {"server": self._server, "protocol": self._protocol}
        items = gkey.find_items_sync(gkey.ITEM_NETWORK_PASSWORD, attrs)
        return (items[0].attributes["user"], items[0].secret)

    def set_credentials(self, (user, pw)):
        attrs = {
                "user": user,
                "server": self._server,
                "protocol": self._protocol,
            }
        gkey.item_create_sync(gkey.get_default_keyring_sync(),
                gkey.ITEM_NETWORK_PASSWORD, self._name, attrs, pw, True)

def get_username(server):
    keyring = Keyring("offlineimap", server, "imap")
    (username, password) = keyring.get_credentials()
    return username

def get_password(server):
    keyring = Keyring("offlineimap", server, "imap")
    (username, password) = keyring.get_credentials()
    return password

folder_mapping = [
        {"local": "inbox", "remote": "INBOX"},
        {"local": "drafts", "remote": "[Gmail]/Drafts"},
        {"local": "sent", "remote": "[Gmail]/Sent Mail"},
        {"local": "starred", "remote": "[Gmail]/Starred"},
        {"local": "trash", "remote": "[Gmail]/Trash"},
        {"local": "chats", "remote": "[Gmail]/Chats"}
        ]

def nametrans_local2remote(folder_name):
    for item in folder_mapping:
        if item["local"] == folder_name:
            return item["remote"]
    return folder_name

def nametrans_remote2local(folder_name):
    for item in folder_mapping:
        if item["remote"] == folder_name:
            return item["local"]
    return folder_name

if __name__ == '__main__':
        server = raw_input("server: ")
        user = raw_input("username: ")
        password = getpass("password: ")
        confirm = getpass("confirm password: ")
        if password != confirm:
            print "password doesn't match confirmation!"
            sys.exit(1)
        keyring = Keyring("offlineimap", server, "imap")
        keyring.set_credentials((user, password))

