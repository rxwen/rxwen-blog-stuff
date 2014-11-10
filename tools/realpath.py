#!/usr/bin/env python
# -*- coding: utf-8 -*-

from os import path
from optparse import OptionParser
import subprocess
import sys

__VERSION__ = '1.0.0'

def copy_sys_clipboard(real_path):
    proc = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
    proc.communicate(real_path)

def main(options, file_to_check):
    if path.exists(file_to_check):
        real_path = path.realpath(file_to_check)
        if options.copy:
            copy_sys_clipboard(real_path)
        if sys.stdout.isatty():
            real_path = real_path + '\n'
        sys.stdout.write(real_path)
    else:
        sys.stderr.write(file_to_check+" doesn't exist\n")

if __name__ == "__main__":
    opt_parser = OptionParser(version = "%prog " + __VERSION__, 
                description = "get real path of specified file",
                usage = "%prog [-c] file_to_check")
    opt_parser.add_option("-c", "--copy", action="store_true", default=False, 
            help="copy output to system clipboard")
    (cmdline_options, args) = opt_parser.parse_args()
    if len(args) != 1:
        opt_parser.print_usage()
        sys.exit(0)
    main(cmdline_options, args[0])
