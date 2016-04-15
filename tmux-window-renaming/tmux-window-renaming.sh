#
# tmux-window-renaming.sh -- Rename tmux windows corresponding to current
# directory in bash OR to command run from bash
# https://github.com/sur98ke/linux_scripts
# 
# Author: Artur Mansurov (sur98reg@gmail.com)
#

# General Usage:
#
# use this script if you meet following conditions:
#   you are using bash as a shell
#   you like using tmux :)
#
# 0. It is recommended to use this script in combination with 
#   https://github.com/rcaloras/bash-preexec
#
# 1. Source this file at the end of your bash profile so as not to interfere
#   with anything else that's using PROMPT_COMMAND.
#
# 2. Run command 'tm' to launch tmux. Now tmux window name follow:
#   * current directory while bash is waiting for a command 
#   * last command started from bash and not yet finished
#   Also if you run tmux from xterm-compatible terminal (putty is 
#   xterm-compatible by default) then name of this terminal 
#   is set to '<user>@<host>:tmux'
#  
# 3. If inside tmux you 'su' or 'sudo -E [-s]' then name of effective user
#   is also displayed in the name of tmux window
# 
# 4. If inside tmux you 'sudo' or 'ssh' AND this script is also installed under
#   the user you are becoming to then name of that user and name of remote host
#   is also displayed in the name of tmux window
#

function tm_my
{
    if [ -z "$TMUX" ] && [ "$TERM" != 'screen' ] ;  then
        export TMUX_USER=$USER
        export TMUX_HOSTNAME=${HOSTNAME%%.*}
        printf "\033]0;%s@%s:%s\007" "${TMUX_USER}" "${TMUX_HOSTNAME}" "tmux"
        #tmux set -q automatic-rename off
        if tmux has ; then tmux attach ; else tmux new ; fi
    else
        echo >&2 "already in tmux"
    fi
}

function tm_prompt
{
    PR_USER=$USER
    PR_HOSTNAME=${HOSTNAME%%.*}
    if [ "$PR_HOSTNAME" = "$TMUX_HOSTNAME" ] ; then
        if [ "$PR_USER" = "$TMUX_USER" ] ; then
            PR_USERHOST=
        else
            PR_USERHOST="$PR_USER@:"
        fi
    else
        PR_USERHOST="$PR_USER@$PR_HOSTNAME:"
    fi
    printf "\033k%s%s\033\\" "${PR_USERHOST}" "$1"
}

function tm_prompt_pwd
{
    tm_prompt "${PWD/#$HOME/~}"
}


if [ "$PS1" ]; then # check for interactive mode
    #PS1='[\u@\h \w]\$ '

    alias tm='tm_my'

    case $TERM in
    screen*)
        if [[ "$__bp_imported" == "defined" ]] ; then # use bash_preexec by Ryan Caloras https://github.com/rcaloras/bash-preexec
            preexec_functions+=(tm_prompt)
             precmd_functions+=(tm_prompt_pwd)
        else
            PROMPT_COMMAND='tm_prompt "${PWD/#$HOME/~}"'

            alias mc='tm_prompt "mc" ; mc'
            alias man='tm_prompt "man" ; man'
            # you might want to add more here
        fi
        ;;
    *)
        ;;
    esac
fi
