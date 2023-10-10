#!/bin/bash

# run this script as root, sudo su -l

array=(sysstat iotop dos2unix nethogs iftop apt-file ipset htop dsniff iftop realpath socat silversearcher-ag zsh ncurses-dev p7zip tofrodos check g++ cppcheck git-core git-extras tig valgrind cgdb nmap ctags cscope expect flex manpages-posix-dev clang libclang-dev astyle)

len=${#array[*]}
i=0
while [ $i -lt $len ]; do
        echo "sudo apt-get install -y ${array[$i]}"
        sudo apt-get install -y ${array[$i]}
            let i++
        done

# add my account to docker group to avoid having to run docker as root: sudo usermod -a -G docker current_user_name
# change docker run time root dir: sudo ln -s /home/raymond/projects/docker/runtime_root /var/lib/docker
# the docker.io/docker in ubuntu repository isn't maintained by docker team and it's out of date,
# it's recommended to use this command to install docker: wget -qO- https://get.docker.com/ | sh

# for chinese input, user fcitx-googlepinyin
# add zsh-completion & zsh-syntax-highlighter plugins for on-my-zsh (place in ~/.oh-my-zsh/custom/plugins/)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
wget https://raw.githubusercontent.com/clvv/fasd/master/fasd

# for serial port accessing, install ckermit
# create "KERNEL=="ttyUSB*", MODE="0666" rule in /etc/udev/rules.d/50-usb-tty.rules,  then use kermit -l /dev/ttyUSB* -b 115200 to access

# additional tools
# smplayer gnome-applets
