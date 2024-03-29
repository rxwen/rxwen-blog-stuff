#!/bin/bash

# run this script as root, sudo su -l
sudo ln -s "$(which fdfind)" /usr/local/bin/fd

# add my account to docker group to avoid having to run docker as root: sudo usermod -a -G docker current_user_name
# change docker run time root dir: sudo ln -s /home/raymond/projects/docker/runtime_root /var/lib/docker
# the docker.io/docker in ubuntu repository isn't maintained by docker team and it's out of date,
# it's recommended to use this command to install docker: wget -qO- https://get.docker.com/ | sh
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# for chinese input, user fcitx-googlepinyin
# add zsh-completion & zsh-syntax-highlighter plugins for on-my-zsh (place in ~/.oh-my-zsh/custom/plugins/)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
chmod +x fasd
sudo mv fasd /usr/local/bin

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

git clone https://github.com/rxwen/myvim_vundle ~/.vim && cd ~/.vim && git submodule update --init --recursive

sed -i 's/plugins=(git)/plugins=(git fasd zsh-syntax-highlighting zsh-completions zsh-autosuggestions git-extras kubectl)/g' ~/.zshrc

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
# for serial port accessing, install ckermit
# create "KERNEL=="ttyUSB*", MODE="0666" rule in /etc/udev/rules.d/50-usb-tty.rules,  then use kermit -l /dev/ttyUSB* -b 115200 to access

# additional tools
# smplayer gnome-applets[
