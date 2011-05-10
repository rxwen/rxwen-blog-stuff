alias vim='/cygdrive/d/vim/vim73/vim.exe'
alias vi='/cygdrive/d/vim/vim73/vim.exe'
alias mgrep='grep --color=auto -n -H --exclude=*.svn-base --exclude=cscope.* -I -r -E -s '
#alias bcscope="echo find source files; find ./ -regex '.*\.\(cpp\|c\|cxx\|cc\|h\|hpp\|hxx\)' > cscope.files; echo build cscope; cscope -b; echo done "
alias bcscope='python $(cygpath -wa $(which bcscope.py))'
alias ls='ls --color=auto'

#export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\][\W]\[\033[00m\]\$ '
export PS1='${debian_chroot:+($debian_chroot)}\u@\h:[\W]\$ '

export PATH=$PATH:/cygdrive/e/android_sdk/ndk/
