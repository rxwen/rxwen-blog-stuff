#!/bin/bash

# run this script as root, sudo su -l

# sun-java6-jdk must be the last one in array
array=(ncurses-dev p7zip tofrodos check g++ cppcheck subversion mercurial git-core gitk valgrind cgdb ipython python-setuptools mit-scheme wireshark nmap vim-gnome ctags cscope expect doxygen sdcv ant sun-java6-jdk)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

