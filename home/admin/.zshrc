#!/bin/zsh
# vim:fdm=marker:

#{{{ Initialization

# Force exit when not running in interactive mode
if [[  "$-" != *i* ]]; then return 0; fi

# Start X automatically if .xinitrc exists
#if [[ -z $DISPLAY && $(tty) = /dev/tty1 && -f $HOME/.xinitrc ]]; then
    #exec startx
#fi

export SHELL=`which zsh`
export LC_ALL="en_US.UTF-8"

# Customize color output
[[ -f $HOME/.lscolors ]] && eval $(dircolors -b $HOME/.lscolors)

# Initialize colors
autoload colors
# Since basically all people use terminals that support bunches of colors,
# It's proper to initialize colors directly
# So that terms within vim can enjoy colorful prompts
colors
#[[ $terminfo[colors] -ge 8 ]] && colors
pR="%{$reset_color%}%u%b" pB="%B" pU="%U"
for i in red green blue yellow magenta cyan white black; {eval pfg_$i="%{$fg[$i]%}" pbg_$i="%{$bg[$i]%}"}

#}}}

#{{{ Settings

setopt complete_aliases       # Do not expand aliases before_ completion has finished
setopt auto_pushd             # Automatically pushd directories on dirstack
setopt auto_continue          # Automatically send SIGCON to disowned jobs
setopt extended_glob          # So that patterns like ^() *~() ()# can be used
setopt pushd_ignore_dups      # Do not push dups on stack
setopt pushd_silent           # Be quiet about pushds and popds
setopt brace_ccl              # Expand alphabetic brace expressions
setopt complete_in_word       # Stay where it is and completion is done from both ends
setopt correct                # Spell check for commands only
setopt hash_list_all          # Search all paths before command completion
setopt hist_ignore_all_dups   # When runing a command several times, only store one
setopt hist_ignore_space      # Do not remember commands starting with space
setopt share_history          # Share history among sessions
setopt hist_verify            # Reload full command when runing from history
setopt hist_expire_dups_first # Remove dups when max size reached
setopt list_types             # Show ls -F style marks in file completion
setopt long_list_jobs         # Show pid in bg job list
setopt numeric_glob_sort      # When globbing numbered files, use real counting
setopt no_hist_beep           # Don not beep on history expansion errors
setopt hist_reduce_blanks     # Reduce whitespace in history
setopt interactive_comments   # Comments in history
setopt inc_append_history     # Append to history once executed
setopt prompt_subst           # Prompt more dynamic, allow function in prompt

# Report to me when other people login/logout
watch=(notme)

# Exclude '/' from WORDCHARS so <Ctrl-w> will only delete part of the path
WORDCHARS="*?_-.[]~=&;!#$%^(){}<>"

# }}}

#{{{ Completion

# Initialize menu completion
autoload -Uz compinit
compinit

zmodload -i zsh/complist
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" "ma=${${use_256color+1;7;38;5;143}:-1;7;33}"

# Ignore list in completion
zstyle ':completion:*' ignore-parents parent pwd directory

# Menu select in completion
zstyle ':completion:*'               menu select=2
zstyle ':completion:*'               completer _oldlist _expand _force_rehash _complete _match
zstyle ':completion:*:match:*'       original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'

# 'kill' completion
zstyle ':completion:*:*:kill:*'           menu yes select
zstyle ':completion:*:*:*:*:processes'    force-list always
zstyle ':completion:*:processes'          command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=1;31"

# Only show pdf files when complete for zathura
zstyle ':completion:*:*:zathura:*:*' file-patterns '(#i)*.{ps,pdf}:files:ps\ or\ pdf\ file *(-/):directories:directories'

# Complete all programs in the PATH for proxychains
compdef _precommand proxychains

# use cache to speed up completion
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path $HOME/.cache/zsh

# Group matches and prompt formats
zstyle ':completion:*:matches'      group            'yes'
zstyle ':completion:*'              group-name       ''
zstyle ':completion:*:options'      description      'yes'
zstyle ':completion:*:options'      auto-description '%d'
zstyle ':completion:*:descriptions' format           $'\e[33m == \e[1;7;36m %d \e[m\e[33m ==\e[m'
zstyle ':completion:*:messages'     format           $'\e[33m == \e[1;7;36m %d \e[m\e[0;33m ==\e[m'
zstyle ':completion:*:warnings'     format           $'\e[33m == \e[1;7;31m No Matches Found \e[m\e[0;33m ==\e[m'
zstyle ':completion:*:corrections'  format           $'\e[33m == \e[1;7;37m %d (errors: %e) \e[m\e[0;33m ==\e[m'

#}}}

#{{{ Prompt

if [ "$SSH_TTY" = "" ]; then
    local host="$pB$pfg_blue%m$pR"
else
    local host="$pB$pfg_magenta%m$pR"
fi

set -A altchar ${(s..)terminfo[acsc]}
local user="$pB%(!:$pfg_red:$pfg_green)%n$pR"
local symbol="$pB%(!:$pfg_red# :$pfg_yellow> )$pR"
local job="%1(j,$pfg_red:$pfg_blue%j,)$pR"
local prompt_time="%(?:$pfg_green:$pfg_red)%*$pR"
typeset -A altchar

PROMPT='$pfg_red%(?..%? )$user$pfg_yellow@$pR$host$(get_prompt_git)$job$symbol'
PROMPT2="$PROMPT$pfg_cyan%_$pR $pB$pfg_black>$pR$pfg_green>$pB$pfg_green>$pR "
RPROMPT='$__PROMPT_PWD'
SPROMPT="${pfg_yellow}zsh$pR: correct '$pfg_red$pB%R$pR' to '$pfg_green$pB%r$pR' ? ([${pfg_cyan}Y$pR]es/[${pfg_cyan}N$pR]o/[${pfg_cyan}E$pR]dit/[${pfg_cyan}A$pR]bort) "

PR_SET_CHARSET="%{$terminfo[enacs]%}"
PR_SHIFT_IN="%{$terminfo[smacs]%}"
PR_SHIFT_OUT="%{$terminfo[rmacs]%}"

zle_highlight=(region:bg=magenta
    special:bold,fg=magenta
    default:bold
    isearch:underline
)

#}}}

#{{{ Functions

# Force rehash when command not found
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}

# Check if a binary exists in path
bin-exist() {[[ -n ${commands[$1]} ]]}

# PWD color
__PROMPT_PWD="$pfg_blue%~$pR"
pwd_color_chpwd() { [ $PWD = $OLDPWD ] || __PROMPT_PWD="$pU$pfg_cyan%~$pR" }
pwd_color_preexec() { __PROMPT_PWD="$pfg_blue%~$pR" }

# Functions to display git branch in prompt
get_git_status() {
    unset __CURRENT_GIT_BRANCH
    unset __CURRENT_GIT_BRANCH_STATUS
    unset __CURRENT_GIT_BRANCH_IS_DIRTY

    [[ "$PWD" = "$HOME" ]]  &&  return
    local dir=$(git rev-parse --git-dir 2>/dev/null)
    [[ "${dir:h}" = "$HOME" ]] && return

    local st="$(git status 2>/dev/null)"
    if [[ -n "$st" ]]; then
        local -a arr
        arr=(${(f)st})

        if [[ $arr[1] =~ 'Not currently on any branch.' ]]; then
            __CURRENT_GIT_BRANCH='no-branch'
        else
            __CURRENT_GIT_BRANCH="${arr[1][(w)4]}";
        fi

        if [[ $arr[2] =~ 'Your branch is' ]]; then
            if [[ $arr[2] =~ 'ahead' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='ahead'
            elif [[ $arr[2] =~ 'diverged' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='diverged'
            elif [[ $arr[2] =~ 'behind' ]]; then
                __CURRENT_GIT_BRANCH_STATUS='behind'
            else
                __CURRENT_GIT_BRANCH_STATUS='up-to-date'
            fi
        fi

        [[ ! $st =~ "nothing to commit" ]] && __CURRENT_GIT_BRANCH_IS_DIRTY='1'
    fi
}

git_branch_precmd() { [[ "$(fc -l -1)" == *git* ]] && get_git_status }

git_branch_chpwd() { get_git_status }

# This one is to be used in prompt
get_prompt_git() {
    if [[ -n $__CURRENT_GIT_BRANCH ]]; then
        local s=$__CURRENT_GIT_BRANCH
        case "$__CURRENT_GIT_BRANCH_STATUS" in
            ahead)    s+="+" ;;
            diverged) s+="=" ;;
            behind)   s+="-" ;;
        esac
        [[ $__CURRENT_GIT_BRANCH_IS_DIRTY = '1' ]] && s+="*"
        echo "$pfg_yellow:$pfg_white$pbg_black$pB $s $pR"
    fi
}

# Functions to set dynamic title
title_precmd() {
    title "`print -Pn "%~" |sed "s:\([~/][^/]*\)/.*/:\1...:;s:\([^-]*-[^-]*\)-.*:\1:"`" "$TERM $PWD"
    echo -ne '\033[?17;0;127c'
}

title_preexec() {
    local -a cmd; cmd=(${(z)1})
    case $cmd[1]:t in
        'ssh')       title "@""`echo $cmd[2]|sed 's:.*@::'`" "$TERM $cmd";;
        'sudo')      title "#"$cmd[2]:t "$TERM $cmd[3,-1]";;
        'for')       title "()"$cmd[7] "$TERM $cmd";;
        'svn'|'git') title "$cmd[1,2]" "$TERM $cmd";;
        'ls'|'ll')   ;;
        *)           title $cmd[1]:t "$TERM $cmd[2,-1]";;
    esac
}

# Active command as title in terminals
case $TERM in
    xterm*|rxvt*)
        function title() { print -nP "\e]0;$1\a" }
        ;;
    *)
        function title() {}
        ;;
esac

# Set functions accordingly
typeset -ga preexec_functions precmd_functions chpwd_functions
precmd_functions+=title_precmd
precmd_functions+=git_branch_precmd
preexec_functions+=title_preexec
preexec_functions+=pwd_color_preexec
chpwd_functions+=pwd_color_chpwd
chpwd_functions+=git_branch_chpwd

# Colorize command as blue if found in path or defined.
TOKENS_FOLLOWED_BY_COMMANDS=('|' '||' ';' '&' '&&' 'sudo' 'do' 'time' 'strace')

recolor-cmd() {
    region_highlight=()
    colorize=true
    start_pos=0
    for arg in ${(z)BUFFER}; do
        ((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]## #}}))
        ((end_pos=$start_pos+${#arg}))
        if $colorize; then
            colorize=false
            res=$(LC_ALL=C builtin type $arg 2>/dev/null)
            case $res in
                *'reserved word'*)   style="fg=magenta,bold";;
                *'alias for'*)       style="fg=cyan,bold";;
                *'shell builtin'*)   style="fg=yellow,bold";;
                *'shell function'*)  style='fg=green,bold';;
                *"$arg is"*)
                    [[ $arg = 'sudo' ]] && style="fg=red,bold" || style="fg=blue,bold";;
                *)                   style='none,bold';;
            esac
            region_highlight+=("$start_pos $end_pos $style")
        fi
        [[ ${${TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]}:+yes} = 'yes' ]] && colorize=true
        start_pos=$end_pos
    done
}
check-cmd-self-insert() { zle .self-insert && recolor-cmd }
check-cmd-backward-delete-char() { zle .backward-delete-char && recolor-cmd }
zle -N self-insert check-cmd-self-insert
zle -N backward-delete-char check-cmd-backward-delete-char

# Add 'sudo' to current line
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line

# Display only the query time of 'dig'
dag() {
    dig "$1" | grep "Query time"
}

# CLI calculator
bbc() {
    echo "scale=4;" "$@" | bc
}

#}}}

#{{{ Mappings

autoload -U zkbd

# Use emacs style keybindings
bindkey -e

typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}
for k in ${(k)key} ; do
    [[ ${key[$k]} == $'\eO'* ]] && key[$k]=${key[$k]/O/[}
done

# Set up key accordingly
[[ -n "${key[Home]}"   ]] && bindkey "${key[Home]}"   beginning-of-line
[[ -n "${key[End]}"    ]] && bindkey "${key[End]}"    end-of-line
[[ -n "${key[Insert]}" ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char
[[ -n "${key[Up]}"     ]] && bindkey "${key[Up]}"     up-line-or-history
[[ -n "${key[Down]}"   ]] && bindkey "${key[Down]}"   down-line-or-history
[[ -n "${key[Left]}"   ]] && bindkey "${key[Left]}"   backward-char
[[ -n "${key[Right]}"  ]] && bindkey "${key[Right]}"  forward-char

autoload history-search-end
autoload -U edit-command-line

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
zle -N edit-command-line

# Fallback mapping for tmux
bindkey '\e\e' sudo-command-line
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[6~' history-beginning-search-forward-end
bindkey '^[[5~' history-beginning-search-backward-end
bindkey '' history-beginning-search-backward-end
bindkey '' history-beginning-search-forward-end
bindkey '^J' backward-word
bindkey '^K' forward-word
bindkey '^\' edit-command-line

# Use the vi navigation keys besides cursor keys in menu completion
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

#}}}

#{{{ Parameters

# Number of lines kept in history
export HISTSIZE=5000

# Number of lines saved in the history after logout
export SAVEHIST=5000

# Location of history
if [[ -d $HOME/.cache/zsh ]]; then
    export HISTFILE=$HOME/.cache/zsh/zsh_history
else
    export HISTFILE=$HOME/.zsh_history
fi

# Additional $PATH for all machines
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

# Environmental variables
export EDITOR=vim
export VISUAL=vim
export SUDO_PROMPT=$'[\e[31;5msudo\e[m] password for \e[33;1m%p\e[m: '

# Colored man pages
export PAGER=less
export LESS_TERMCAP_md=$'\E[1;31m'
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_me=$'\E[m'
export LESS_TERMCAP_so=$'\E[01;7;34m'
export LESS_TERMCAP_se=$'\E[m'
export LESS_TERMCAP_us=$'\E[1;2;32m'
export LESS_TERMCAP_ue=$'\E[m'
export LESS="-M -i -R --shift 5"
export LESSCHARSET=utf-8
export READNULLCMD=less

# Quartus related
export QUARTUSPATH=$HOME/opt/intelFPGA_lite/18.1
export PATH=$PATH:${QUARTUSPATH}/quartus/bin
export PATH=$PATH:${QUARTUSPATH}/nios2eds/bin

# Redefine command not found
(bin-exist cowsay) && (bin-exist fortune) && command_not_found_handler() { fortune -s| cowsay -W 70}

#}}}

#{{{ Alias

# Remove output color
alias -g B='|sed -r "s:\x1B\[[0-9;]*[mK]::g"'

# The last-modified file
alias -g NM="*(oc[1])"

for i in mkdir mv cp;  alias $i="nocorrect $i"

alias grep='grep -I --color=auto'
alias egrep='egrep -I --color=auto'
alias cal='cal -3'
alias freeze='kill -STOP'
alias ls=$'ls -h --color=auto -X --time-style="+\e[33m[\e[32m%Y-%m-%d \e[35m%k:%M\e[33m]\e[m"'
alias free='free -m'
alias df='df -hT'
alias dog='dig archlinux.org | grep "Query time"'
alias du='du -hs'
alias ps='ps -Aa'
alias uuid='ls -al /dev/disk/by-uuid'
alias xp='xprop|grep "WM_WINDOW_ROLE\|WM_CLASS" && echo "WM_CLASS(STRING) = \"NAME\", \"CLASS\""'
alias xe="xev|grep -A2 --line-buffered '^KeyRelease'|sed -n \
              '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'"

#}}}
