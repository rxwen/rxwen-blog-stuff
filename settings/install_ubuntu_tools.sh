#!/bin/bash

# run this script as root, sudo su -l

# sun-java6-jdk must be the last one in array
array=(tofrodos check g++ subversion mercurial git-core valgrind cgdb ipython python-setuptools mit-scheme wireshark nmap vim-gnome ctags cscope expect scim-chinese ant sun-java6-jdk)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

