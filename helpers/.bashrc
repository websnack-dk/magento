#!/bin/bash

#GENERAL BASH SETTINGS
HISTCONTROL=ignoreboth:erasedups HISTSIZE=100000 HISTFILESIZE=200000
ls --color=al > /dev/null 2>&1 && alias ls='ls -F --color=al' || alias ls='ls -G'
export PS1="[\[$(tput setaf 3)\]\t\[$(tput sgr0)\]][\[$(tput setaf 6)\]\u\[$(tput sgr0)\]][\[$(tput setaf 1)\]\w\[$(tput sgr0)\]]\\$ >\n\[$(tput sgr0)\]"
#PS2='\[\033[01;36m\]>'

###+ ALIASES + ###
alias magento="bin/compile.sh"

alias m="bin/magento"
alias composer1="composer self-update --1"
alias composer2="composer self-update --2"
alias mdev="bin/magento deploy:mode:set developer"
alias mclean="bin/magento cache:clean"
alias mflush="bin/magento cache:flush"
alias mdeploy="bin/magento setup:static-content:deploy -f && bin/magento setup:static-content:deploy -f da_DK"
alias mcompile="bin/magento setup:di:compile"
alias mupgrade="bin/magento setup:upgrade"
alias mindexer="bin/magento indexer:reindex"
alias mcron="bin/magento cron:run"
