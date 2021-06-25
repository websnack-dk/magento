#!/bin/bash

# shellcheck source=./setup/helpers
source "$(dirname "$0")/setup/helpers"

# shellcheck source=./setup/select_option
source "$(dirname "$0")/setup/select_option"


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

base_ddev_setup() {
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/.bashrc            --output .ddev/homeadditions/.bashrc  --create-dirs --silent
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/config.local.yaml   --output .ddev/config.local.yaml       --silent
    echo "$COLOR_GREEN Added .bashrc & config.local.yaml $COLOR_REST"

    # Exclude backup-folder, project-stopped from IDE (Phpstorm)
    local FOLDER_NAME="${PWD##*/}"
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/phpstorm/exclude_project_stopped.iml  --output ".idea/${FOLDER_NAME}.iml" --create-dirs --silent
    #sed -i '' "s%\${DDEV_PROJECT}%${FOLDER_NAME}%g" .idea/"${FOLDER_NAME}".iml
    echo "$COLOR_GREEN Config to exclude backup folder added $COLOR_REST"
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

### OBSERVER SCRIPT ###
install_observer() {

  if [ ! -f ".ddev/commands/web/observer" ]; then
    printf '%s\n' "$COLOR_BLUE [!] Adding observer setup $COLOR_REST"
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/observer --output .ddev/commands/web/observer --create-dirs --silent
    ddev observer
    printf '%s\n' "$COLOR_GREEN Virtualenv has been setup $COLOR_REST"
  fi
}
add_watch_observer() {

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

## Choices
setup_existing_project() {
  retrieve_helpers
  printf '%s\n' "$COLOR_BLUE Creating .ddev folder $COLOR_REST"
  ddev config --project-type=magento2 --docroot=pub --create-docroot
  printf '%s\n' "$COLOR_GREEN .ddev folder created $COLOR_REST"

  create_elasticsearch
  base_ddev_setup
  install_mutagen

  checklist
}
setup_clean_magento2_install() {

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
                  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/setup_clean_magento2_install   --output .ddev/commands/web/setup_clean_magento2_install  --silent
                  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/.gitignore               --output .gitignore                                 --silent

                  if [ ! -f "composer.json" ]; then
                    ddev start
                    ddev composer create --repository=https://repo.magento.com/ magento/project-community-edition
                    ddev stop
                  fi

                  create_elasticsearch
                  retrieve_helpers
                  base_ddev_setup
                  install_mutagen

                  ddev start
                  ddev setup_clean_magento2_install

                  exit 0
              ;;

              "No" )
                  exit 1
              ;;

          esac
      done

  fi

}


setup_tailwind_theme() {
  echo "CURL TAILWIND THEME & Setup base";
}

logo

# Choose setup
PS3="Choose setup (enter number): "
setupOptions=(
  "1. Setup Script (Existing Project)"
  "2. With Observer (Existing project)"
  "3. Integrate Tailwindcss (Existing project)"
  "4. Clean Magento2 Install (v2.4.2)"
  "5. Quit")

# echo -e "========================================================================="

case $(select_opt "${setupOptions[@]}") in

    0)
        if [ "$(is_existing_project)" == "0" ]; then
            echo "Setup existing project"

            exit 1
        fi
        exit 0
    ;;

    1)
        # setup_setup_existing_project
        # add_watch_observer
        # install_observer
    ;;

    2)
        # setup_existing_project
        echo "you chose new install"
        # setup_clean_magento2_install
        exit 1
    ;;

    3)
        echo "you chose Base/Tailwind"
        # setup_tailwind_theme
        exit 1
      ;;

    *) exit 0  ;;
esac
