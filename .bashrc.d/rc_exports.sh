#!/usr/bin/env bash

# {{ Deal the path first
# Add `~/bin` to the `$PATH`
(echo $PATH | grep "$HOME/bin:" > /dev/null )|| export PATH="$HOME/bin:$PATH"
# }}

# Make vim the default editor
export EDITOR="vim"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
# Make some commands not show up in history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date"

# Prefer US English and use UTF-8
export LANG="en_US"
export LC_ALL="en_US.UTF-8"
# 如果是在 linux 的终端下,则不显示中文, 因为基本不支持 :-)
termis linux || {
    export LANG="zh_CN"
    export LC_ALL="zh_CN.UTF-8"
}
# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Color man pages: {{

export LESS_TERMCAP_mb=$'\E[01;31m'      # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'      # begin bold
export LESS_TERMCAP_me=$'\E[0m'          # end mode
export LESS_TERMCAP_se=$'\E[0m'          # end standout-mode                 
export LESS_TERMCAP_so=$'\E[01;44;33m'   # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'          # end underline
export LESS_TERMCAP_us=$'\E[01;32m'      # begin underline

# }}


# vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={{,}} foldlevel=0 foldmethod=marker:
