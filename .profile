#!/bin/sh
################################################################################
## .profile
## 2013-06-03
################################################################################
## This file is sourced by .xprofile and shell rc files to make sure it work in
## TTY as well as under X.

## Mask
## Result for 027 is: rwxr-x---
umask 027

## Path
## WARNING: putting current dir '.' in PATH is mostly a bad idea!
# export PATH=.:$PATH
export PATH=$PATH:${HOME}/.launchers/
export PATH=$PATH:${HOME}/.scripts/

## TeXlive
TEXDIR="${TEXDIR:-/usr/local/texlive}"
if [ -d "${TEXDIR}" ]; then
    TEXYEAR=$(/bin/ls -1r "${TEXDIR}" | grep -m1 "[0-9]\{4\}")
    TEXDISTRO=$(uname -m)-$(uname | tr "[[:upper:]]" "[[:lower:]]")
    TEXFOLDER="${TEXDIR}/${TEXYEAR}/bin/${TEXDISTRO}/"
    if [ -d "${TEXFOLDER}" ]; then
        export PATH=${TEXFOLDER}:$PATH
        export INFOPATH=${TEXDIR}/${TEXYEAR}/texmf/doc/info:$INFOPATH

        ## BSD uses 'manpath' utility, so MANPATH variable may be empty.
        if [ "$OSTYPE" = "linux-gnu" ]; then
            export MANPATH=${TEXDIR}/${TEXYEAR}/texmf/doc/man:$MANPATH
        fi
    fi
    unset TEXYEAR
    unset TEXDISTRO
    unset TEXFOLDER
fi
unset TEXDIR

## Make 'less' more friendly for non-text input files, see lesspipe(1).
[ -n "$(command -v lesspipe)" ] && eval "$(lesspipe)"

## Manpage.
export MANPAGER="less -s"
export MANWIDTH=80
## The following options are useful for FreeBSD default 'less' command which has
## an empty prompt. Sadly this gets messy with 'apropos'.
# export MANPAGER="less -sP '?f%f .?m(file %i of %m) .?ltlines %lt-%lb?L/%L. .byte %bB?s/%s. ?e(END) :?pB%pB\%..%t'"

## Less config. -R is needed for lesspipe.
export LESS=' -R '

## Time display (with ls command for example)
## TODO: BSD version?
export TIME_STYLE=+"|%Y-%m-%d %H:%M:%S|"

## System locale
# export LC_MESSAGES=fr_FR.utf8

## Default text editor
EDITOR="nano"
[ -n "$(command -v vim)" ] && EDITOR="vim"
[ -n "$(command -v emacs)" ] && EDITOR="emacs"
GIT_EDITOR="$EDITOR"

## 'em' is a script for emacsclient. See 'homeinit'.
if [ -n "$(command -v em)" ]; then
   EDITOR='em'
   GIT_EDITOR='emc'
fi
export EDITOR
export GIT_EDITOR

## Internet Browser
[ -n "$(command -v luakit)" ] && export BROWSER="luakit"
[ -n "$(command -v dwb)" ] && export BROWSER="dwb"

## SSH-Agent
## WARNING: this is somewhat insecure. Avoid using it on a mutli-user machine.
if [ -n "$(command -v ssh-agent)" ]; then
    SSH_ENV_FILE="/tmp/ssh-agent-env"
    if [ $(ps ax -o command="" | grep -c "ssh-agent") -eq 1 ]; then
        SSH_AGENT_VARS=$(ssh-agent)
        eval $(echo "${SSH_AGENT_VARS}")
        echo "${SSH_AGENT_VARS}" | sed '2q' | cut -d'=' -f2  | cut -d';' -f1 > "$SSH_ENV_FILE"
        chmod 444 "$SSH_ENV_FILE"
        unset $SSH_AGENT_VARS
    elif [ -f "$SSH_ENV_FILE" ]; then
        SSH_AUTH_SOCK=$(sed -n '1{p;q}' "$SSH_ENV_FILE") ; export SSH_AUTH_SOCK
        SSH_AGENT_PID=$(sed -n '2{p;q}' "$SSH_ENV_FILE") 2>/dev/null ; export SSH_AGENT_PID
    fi
    unset SSH_ENV_FILE
fi