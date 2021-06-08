#GENERAL BASH SETTINGS
HISTCONTROL=ignoreboth:erasedups HISTSIZE=100000 HISTFILESIZE=200000
ls --color=al > /dev/null 2>&1 && alias ls='ls -F --color=al' || alias ls='ls -G'
export PS1="[\[$(tput setaf 3)\]\t\[$(tput sgr0)\]][\[$(tput setaf 6)\]\u\[$(tput sgr0)\]][\[$(tput setaf 1)\]\w\[$(tput sgr0)\]]\\$ >\n\[$(tput sgr0)\]"
#PS2='\[\033[01;36m\]>'
###+ ALIASES + ###
