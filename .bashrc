#if [ -x $f ]; then
#fi
for f in ~/.sh.d/*.sh; do
    . $f
done
[[ -s ~/.sh.d/nix/nix.sh ]] && . ~/.sh.d/nix/nix.sh

[[ -f /etc/bash_completion ]] && . /etc/bash_completion
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -f ~/.bash_functions ]] && . ~/.bash_functions
[[ -f ~/.bash_shopt ]] && . ~/.bash_shopt

xhost +local:root > /dev/null 2>&1

complete -cf sudo

# vars
export HISTSIZE=10000
export HISTFILESIZE=${HISTSIZE}
export HISTCONTROL=ignoreboth

#export EDITOR=vim
#export PULSE_LATENCY_MSEC=60

# no wrap systemd journal
export SYSTEMD_LESS=FRXMK

# prompt
PS1='[\u@\h \W]\$ '
