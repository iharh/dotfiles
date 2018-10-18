#if [ -x $f ]; then
#fi
for f in ~/.sh.d/*.sh; do
    . $f
done
#[[ -s ~/.sh.d/nix/nix.sh ]] && . ~/.sh.d/nix/nix.sh

# TBD: move stuff out of the aliases
[[ -f ~/.zsh_aliases ]] && . ~/.zsh_aliases

# keys
bindkey -v
#-e

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(vi_mode context dir rbenv vcs)
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)
# problem with status
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)
POWERLEVEL9K_PROMPT_ON_NEWLINE=false
POWERLEVEL9K_VI_INSERT_MODE_STRING=I
POWERLEVEL9K_VI_COMMAND_MODE_STRING=N
#POWERLEVEL9K_STATUS_OK_IN_NON_VERBOSE=false
#POWERLEVEL9K_MODE='awesome-patched' // 'awesome-fontconfig'
#POWERLEVEL9K_STATUS_VERBOSE=false
#POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'
POWERLEVEL9K_OK_ICON=$'\u2192'
# $echo $'\u2192'
#POWERLEVEL9K_ERROR_ICON='1'

# plugins

# Check if zplug is installed
[[ -d ~/.zplug ]] || {
  curl -fLo ~/.zplug/zplug --create-dirs https://git.io/zplug
  source ~/.zplug/zplug && zplug update --self
}

source ~/.zplug/zplug

# Make sure to use double quotes to prevent shell expansion
#zplug "zsh-users/zsh-history-substring-search"
zplug "bhilburn/powerlevel9k", of:powerlevel9k.zsh-theme
zplug "joel-porquet/zsh-dircolors-solarized"
zplug "zlsun/solarized-man"
zplug "zsh-users/zsh-syntax-highlighting"

# Install plugins that have not been installed yet
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  else
    echo
  fi
fi

zplug load
#--verbos

# strange, but nvm.zsh does not work if inserted before
for f in ~/.sh.d/*.zsh; do
    . $f
done

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc' #'/home/iharh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# compdef _pass pass
# rm -f ~/.zcompdump; compinit
#setopt completealiases

# man zshcomp...

##zstyle ':completion:*' verbose yes
#zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
#zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
##zstyle ':completion:*:messages' format '%d'
##zstyle ':completion:*' group-name ''

##zstyle ":completion:*:commands" rehash 1

#zstyle ':completion:*' group-order \
#  builtins expansions aliases functions commands globbed-files \
#  directories hidden-files hidden-directories \
#  boring-files boring-directories keywords viewable

#keys
autoload zkbd
function zkbd_file() {
    [[ -f ~/.zkbd/${TERM}-${VENDOR}-${OSTYPE} ]] && printf '%s' ~/".zkbd/${TERM}-${VENDOR}-${OSTYPE}" && return 0
    [[ -f ~/.zkbd/${TERM}-${DISPLAY}          ]] && printf '%s' ~/".zkbd/${TERM}-${DISPLAY}"          && return 0
    return 1
}

[[ ! -d ~/.zkbd ]] && mkdir ~/.zkbd
keyfile=$(zkbd_file)
ret=$?
if [[ ${ret} -ne 0 ]]; then
    zkbd
    keyfile=$(zkbd_file)
    ret=$?
fi
if [[ ${ret} -eq 0 ]] ; then
    source "${keyfile}"
else
    printf 'Failed to setup keys using zkbd.\n'
fi
unfunction zkbd_file; unset keyfile ret

# setup key accordingly
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
# vim-mode only
bindkey '^R' history-incremental-search-backward

#https://dustri.org/b/my-zsh-configuration.html
