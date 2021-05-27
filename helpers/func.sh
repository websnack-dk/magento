#!/bin/bash

YELLOW="33"
BOLD_YELLOW="\e[1;${YELLOW}m"
END_COLOR="\e[0m"

# Output message
function message() {
  message=$1
  echo -e "${BOLD_YELLOW} ${message} ${END_COLOR}";
}

function isTrue() {
  if [[ "${*^^}" =~ ^(TRUE|OUI|Y|O$|ON$|[1-9]) ]]; then return 0; fi
  return 1
}
