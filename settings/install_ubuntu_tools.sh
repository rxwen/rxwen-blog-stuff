#!/bin/bash

# run this script as root, sudo su -l

# sun-java6-jdk must be the last one in array
array=(parcellite zsh fasd mpg123 sysv-rc-conf ncurses-dev p7zip tofrodos check g++ cppcheck pylint mercurial git-core gitk tig git-svn valgrind cgdb python-pip wireshark nmap vim-gnome ctags cscope expect flex doxygen graphviz sdcv dmenu ant manpages-posix-dev clang libclang-dev astyle global)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

