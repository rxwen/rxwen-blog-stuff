#!/bin/bash

# run this script as root, sudo su -l

# sun-java6-jdk must be the last one in array
array=(gpick gnupg2 silversearcher-ag shutter parcellite zsh fasd mpg123 ncurses-dev p7zip tofrodos check g++ cppcheck pylint mercurial git-core gitk tig git-svn valgrind cgdb python-pip wireshark nmap vim-gnome ctags cscope expect flex doxygen graphviz pandoc goldendict sdcv dmenu ant manpages-posix-dev clang libclang-dev astyle global libc6-dev-i386)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

