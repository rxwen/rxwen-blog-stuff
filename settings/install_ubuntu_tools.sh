#!/bin/bash

# run this script as root, sudo su -l

# sun-java6-jdk must be the last one in array
array=(openssh-server awesome awesome-extra gnome-settings-daemon realpath socat gpick gnupg2 silversearcher-ag shutter parcellite zsh fasd mpg123 ncurses-dev p7zip tofrodos check g++ cppcheck pylint mercurial git-core gitk tig git-svn valgrind cgdb python-pip wireshark nmap vim-gnome ctags cscope expect flex doxygen graphviz pandoc goldendict sdcv dmenu ant manpages-posix-dev clang libclang-dev astyle global libc6-dev-i386)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

# add my account to docker group to avoid having to run docker as root: sudo usermod -a -G docker current_user_name
# change docker run time root dir: sudo ln -s /home/raymond/projects/docker/runtime_root /var/lib/docker

# for chinese input, user fcitx-googlepinyin
# add zsh-completion & zsh-syntax-highlighter plugins for on-my-zsh (place in ~/.oh-my-zsh/custom/plugins/)

# for serial port accessing, install ckermit
# create "KERNEL=="ttyUSB*", MODE="0666" rule in /etc/udev/rules.d/50-usb-tty.rules,  then use kermit -l /dev/ttyUSB* -b 115200 to access

# additional tools
# smplayer gnome-applets
