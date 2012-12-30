#!/bin/bash

# run this script as root, sudo su -l

# sun-java6-jdk must be the last one in array
array=(sysv-rc-conf ncurses-dev p7zip tofrodos check g++ cppcheck pylint mercurial git-core gitk valgrind cgdb ipython python-pip mit-scheme wireshark nmap vim ctags cscope expect flex doxygen graphviz sdcv dmenu ant manpages-posix-dev)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

