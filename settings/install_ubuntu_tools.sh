#!/bin/bash

# run this script as root, sudo su -l

array=(fd-find sysstat iotop dos2unix nethogs iftop apt-file ipset htop dsniff iftop openssh-server awesome awesome-extra gnome-settings-daemon realpath socat proxychains gpick gnupg2 silversearcher-ag shutter parcellite zsh mpg123 ncurses-dev p7zip tofrodos check g++ cppcheck mercurial git-core git-extras gitk tig git-svn valgrind cgdb python-pip wireshark nmap vim-gnome ctags cscope expect flex doxygen graphviz pandoc goldendict sdcv dmenu manpages-posix-dev clang libclang-dev astyle global libc6-dev-i386 autossh glances zoxide)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

bash ./install_server_tools.sh
