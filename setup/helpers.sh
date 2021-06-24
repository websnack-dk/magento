#!/bin/bash

release_version () {
   curl --silent "https://github.com/websnack-dk/magento/releases/latest" | sed 's#.*tag/\(.*\)\".*#\1#'
}

COLUMNS=24
COLOR_REST="$(tput sgr0)"
COLOR_GREEN="$(tput setaf 2)"
COLOR_RED="$(tput setaf 1)"
COLOR_YELLOW="$(tput setaf 3)"
COLOR_BLUE="$(tput setaf 4)"

VERSION="$(release_version)"
MAGENTO_VERSION="2.4.2"


error_message() {
    echo "${COLOR_RED}[!] Doesn't look to be a compatible magento2 project${COLOR_REST}"
}

checklist() {
    echo "$COLOR_GREEN###############################################"
    echo "#                                             #"
    echo "#  Follow steps before opening                #"
    echo "#  your project in a browser.                 #"
    echo "#                                             #"
    echo "###############################################"
    echo
    echo "   1. Import existing SQL                     "
    echo "        ddev import-db                        "
    echo
    echo "----------------------------------------------"
    echo
    echo "   2. ddev start                              "
    echo
    echo "----------------------------------------------"
    echo
    echo "   3. ddev ssh & run                          "
    echo "        magento deploy                        "
    echo
    echo "$COLOR_REST"
}

# Check version from composer file (output, success=0
check_magento_version() {
  grep -q '"magento/product-community-edition": "'$MAGENTO_VERSION'"' "composer.json" && echo $?
}

is_existing_project() {
    check_magento_version
}


logo() {

  local logo="
  ███╗   ███╗ █████╗  ██████╗ ███████╗███╗   ██╗████████╗ ██████╗ ██████╗
  ████╗ ████║██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██╔═══██╗╚════██╗
  ██╔████╔██║███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║   ██║ █████╔╝
  ██║╚██╔╝██║██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║██╔═══╝
  ██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   ╚██████╔╝███████╗
  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚══════╝"

    echo -e "\033[1;33m $logo \033[0m"
    echo -e "${COLOR_YELLOW}"
    echo -e "                             Base setup $VERSION"
    echo -e "${COLOR_REST}"

}
