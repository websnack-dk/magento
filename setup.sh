#!/bin/bash

COLOR_REST="$(tput sgr0)"
COLOR_GREEN="$(tput setaf 2)"
COLOR_RED="$(tput setaf 1)"
COLOR_YELLOW="$(tput setaf 3)"
COLOR_BLUE="$(tput setaf 4)"

declare -r VERSION="2.3.0"

# Is docker installed!?
if ! command -v docker &> /dev/null; then
    # Prompt for auto install or exit
    printf '%s' "$COLOR_RED Docker not found. Install it. $COLOR_REST"
    echo "$COLOR_BLUE https://docs.docker.com/desktop/ $COLOR_REST"
    exit 1
fi

# Check if DDEV is installed in system
if ! command -v ddev &> /dev/null; then
    # Prompt for auto install or exit
    read -r -p "$COLOR_RED DDEV not found.$COLOR_REST $COLOR_GREEN Do you want to install? (Y/n) $COLOR_REST" answer
    case ${answer:0:1} in
      y|Y|Yes )
          brew install drud/ddev/ddev
          printf '%s\n' "$COLOR_GREEN DDEV successfully installed $COLOR_REST"
      ;;
      * )
          exit 1
      ;;
    esac
fi


logo() {

  local logo="
  ███╗   ███╗ █████╗  ██████╗ ███████╗███╗   ██╗████████╗ ██████╗ ██████╗
  ████╗ ████║██╔══██╗██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██╔═══██╗╚════██╗
  ██╔████╔██║███████║██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║   ██║ █████╔╝
  ██║╚██╔╝██║██╔══██║██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║██╔═══╝
  ██║ ╚═╝ ██║██║  ██║╚██████╔╝███████╗██║ ╚████║   ██║   ╚██████╔╝███████╗
  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚══════╝"

    echo -e "\033[1;33m $logo \033[0m"
    echo -e "${COLOR_YELLOW}
                               Project setup
                                  v$VERSION ${COLOR_REST}
                           "
}

create_elasticsearch() {
    if [ ! -f ".ddev/docker-compose.elasticsearch.yaml" ]; then
      curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/docker-compose/docker-compose.elasticsearch.yaml --output .ddev/docker-compose.elasticsearch.yaml  --create-dirs --silent
      printf '%s\n' "$COLOR_GREEN Docker-compose.elasticsearch.yaml added $COLOR_REST"
    fi
}
install_mutagen() {
  # Setup mutagen if not already set
  if [ ! -f ".ddev/commands/host/mutagen" ]; then
    printf '%s\n' "$COLOR_YELLOW Setting up mutagen sync script in current ddev project $COLOR_REST"
    curl https://raw.githubusercontent.com/williamengbjerg/ddev-mutagen/master/setup.sh | bash
  fi
}
install_observer() {
  if [ ! -f ".ddev/commands/web/observer" ]; then
    printf '%s\n' "$COLOR_BLUE [!] Adding observer setup $COLOR_REST"
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/observer --output .ddev/commands/web/observer --create-dirs --silent
    ddev observer
    printf '%s\n' "$COLOR_GREEN Virtualenv has been setup $COLOR_REST"
  fi
}
base_ddev_setup() {

    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/.bashrc            --output .ddev/homeadditions/.bashrc  --create-dirs --silent
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/config.local.yaml   --output .ddev/config.local.yaml       --silent
    echo "$COLOR_GREEN Added .bashrc & config.local.yaml $COLOR_REST"

    # Exclude backup-folder, project-stopped from IDE (Phpstorm)
    local FOLDER_NAME="${PWD##*/}"
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/phpstorm/exclude_project_stopped.iml  --output ".idea/${FOLDER_NAME}.iml" --create-dirs --silent
    #sed -i '' "s%\${DDEV_PROJECT}%${FOLDER_NAME}%g" .idea/"${FOLDER_NAME}".iml
    echo "$COLOR_GREEN Config to exclude backup folder added $COLOR_REST"

    # Install pip3 from dockerfile
    if [[ -d ".ddev/web-build" && -f ".ddev/web-build/Dockerfile.example" ]]; then

        # copy file
        cat .ddev/web-build/Dockerfile.example > .ddev/web-build/Dockerfile
        # write to file
        cat >> .ddev/web-build/Dockerfile << 'config'

# Install pip3
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends --no-install-suggests python3-pip python3-setuptools
RUN pip3
config

        printf '%s\n' "$COLOR_GREEN Dockerfile added in web-build $COLOR_REST"
    fi
}
retrieve_helpers() {

  # Copy files from github
  printf '%s\n' "$COLOR_BLUE Downloading helper files $COLOR_REST"
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/compile.sh   --output  bin/compile.sh  --create-dirs --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/helpers.sh   --output  bin/helpers.sh  --create-dirs --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/func.sh      --output  bin/func.sh     --create-dirs --silent

  # make files executable
  chmod +x bin/helpers.sh
  chmod +x bin/compile.sh
  chmod +x bin/func.sh
  printf '%s\n' "$COLOR_GREEN Helper files downloaded to bin folder $COLOR_REST"
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

## Choices
existing_project() {
  retrieve_helpers
  printf '%s\n' "$COLOR_BLUE Creating .ddev folder $COLOR_REST"
  ddev config --project-type=magento2 --docroot=pub --create-docroot
  printf '%s\n' "$COLOR_GREEN .ddev folder created $COLOR_REST"

  create_elasticsearch
  base_ddev_setup
  install_observer
  install_mutagen

  checklist
}
clean_magento2_install() {

  # Fresh clean magento2 install
  if [[ ! -d "bin" || ! -d "pub" ]]; then

      # Prompt for a clean magento2 install
      echo "${COLOR_YELLOW}Fresh Magento2 project install? (Y/n) ${COLOR_REST}"

      select answer in "Yes" "No"; do

          case $answer in
              "Yes" )

                  # Let ddev create some base folders
                  echo "$COLOR_GREEN Installing setup_magento2 script $COLOR_REST"

                  ddev config --project-type=magento2 --docroot=pub --create-docroot
                  mkdir -p .ddev/commands/web/
                  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/clean_magento2_install   --output .ddev/commands/web/clean_magento2_install  --silent
                  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/.gitignore               --output .gitignore                                 --silent

                  if [ ! -f "composer.json" ]; then
                    ddev start
                    ddev composer create --repository=https://repo.magento.com/ magento/project-community-edition
                    ddev stop
                  fi

                  create_elasticsearch
                  retrieve_helpers
                  base_ddev_setup
                  install_observer
                  install_mutagen

                  ddev start
                  ddev clean_magento2_install

                  exit 0
              ;;
              "No" )
                  exit 1
              ;;
          esac
      done

  fi

}

logo

echo -e "${COLOR_YELLOW}Please choose magento2 setup: ${COLOR_REST}"

PS3="Enter choice (number): "
setupOptions=(
  "Existing"        # Existing setup
  "New install"     # Fresh clean magento2 install
  "Base/Tailwind"   # Existing project with Tailwind setup
  "Quit"
)

select selectedSetup in "${setupOptions[@]}"; do

    case $selectedSetup in
        Existing)
            #existing_project
            echo "you chose existing"
          ;;
        "New install")
            # echo "you chose new install"
            clean_magento2_install
            exit 0
          ;;
        "Base/Tailwind")
            echo "you chose Base/Tailwind"
          #echo "Existing setup with Tailwind setup in frontend"
          ;;
        *) exit ;;
    esac

done
