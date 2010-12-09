# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile
#umask 022
# export DISPLAY=192.168.0.1:0.0
export LANG=en_US.UTF-8

if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f ~/.bashrc ]; then
	. ~/.bashrc
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"    
fi

export EDITOR=vim
export JAVA_HOME=/usr/lib/jvm/java-6-sun
export PATH=$JAVA_HOME/bin/:$PATH
export ANDROID_HOME=~/android-sdk-linux_x86/
export PATH=$ANDROID_HOME/tools/:$ANDROID_HOME/platform-tools:$ANDROID_HOME/ndk:$PATH
export ANDROID_JAVA_HOME=$JAVA_HOME
export PYTHONPATH=$HOME/python_libs

# setup machine specific environment variables sotred in .env
# !! make sure this file exist or login may fail
. ~/.env
