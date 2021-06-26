#!/bin/bash

# Setup
curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/setup/helpers.sh     --output __setup__/helpers.sh     --create-dirs --silent
curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/setup/select_option  --output __setup__/select_option  --create-dirs --silent

sleep 0.5

chmod +x __setup__/helpers.sh
chmod +x __setup__/select_option

# shellcheck source=./__setup__/helpers.sh
source __setup__/helpers.sh
# shellcheck source=./__setup__/select_option
source __setup__/select_option

# Is docker installed!?
if ! command -v docker &> /dev/null; then
    # Prompt for auto install or exit
    printf '%s' "$COLOR_RED [X] Docker not found. Install it. $COLOR_REST"
    echo "$COLOR_BLUE https://docs.docker.com/desktop/ $COLOR_REST"
    exit 1
fi

# Check if DDEV is installed in system
if ! command -v ddev &> /dev/null; then
    # Prompt for auto install or exit
    read -r -p "$COLOR_RED [X] DDEV not found $COLOR_REST $COLOR_GREEN [?] Do you want to install DDEV? (Y/n) $COLOR_REST" answer
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
      printf '%s\n' "$COLOR_GREEN [√] elasticsearch added $COLOR_REST"
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
    echo "$COLOR_GREEN [√] .bashrc, config.local.yaml added $COLOR_REST"

    # Exclude backup-folder, project-stopped from IDE (Phpstorm)
    local FOLDER_NAME="${PWD##*/}"
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/phpstorm/exclude_project_stopped.iml  --output ".idea/${FOLDER_NAME}.iml" --create-dirs --silent
    #sed -i '' "s%\${DDEV_PROJECT}%${FOLDER_NAME}%g" .idea/"${FOLDER_NAME}".iml
    echo "$COLOR_GREEN [√] Config to exclude backup folder added $COLOR_REST"
}
retrieve_helpers() {

  # Copy files from github
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/compile.sh   --output  bin/compile.sh  --create-dirs --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/helpers.sh   --output  bin/helpers.sh  --create-dirs --silent
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/func.sh      --output  bin/func.sh     --create-dirs --silent

  # make files executable
  chmod +x bin/helpers.sh
  chmod +x bin/compile.sh
  chmod +x bin/func.sh
  printf '%s\n' "$COLOR_GREEN [√] Helper files downloaded to bin folder $COLOR_REST"
}

### OBSERVER SCRIPT ###
install_observer() {

  if [ ! -f ".ddev/commands/web/observer" ]; then
    printf '%s\n' "$COLOR_GREEN [√] Adding observer setup $COLOR_REST"
    curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/observer --output .ddev/commands/web/observer --create-dirs --silent
    ddev observer
    printf '%s\n' "$COLOR_GREEN [√] Virtualenv has been setup $COLOR_REST"
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

        printf '%s\n' "$COLOR_GREEN [√] Dockerfile added $COLOR_REST"
    fi
}

setup_existing_project() {
  retrieve_helpers
  ddev config --project-type=magento2 --docroot=pub --create-docroot
  printf '%s\n' "$COLOR_GREEN [√] Folder created (.ddev) $COLOR_REST"

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
                  echo "$COLOR_YELLOW [!] Installing magento2 $COLOR_REST"

                  ddev config --project-type=magento2 --docroot=pub --create-docroot
                  mkdir -p .ddev/commands/web/
                  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/clean_magento2_install         --output .ddev/commands/web/setup_clean_magento2_install  --silent
                  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/.gitignore                     --output .gitignore                                       --silent

                  if [ ! -f "composer.json" ]; then
                    ddev start
                    ddev composer create --repository=https://repo.magento.com/ magento/project-community-edition=2.4.2
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
  echo "$COLOR_YELLOW [!] Tailwind setup script is not yet ready $COLOR_REST";
  exit 0
}

remove_setup_folder() {
  rm -rf __setup__
}

logo

## Setup choices
setupOptions=(
  "1. Setup Script (Existing Project)"
  "2. With Observer (Existing project)"
  "3. Integrate Tailwindcss (Existing project)"
  "4. Clean Magento2 Install (v2.4.2)"
  "Quit")

case $(select_opt "${setupOptions[@]}") in

    ## Base setup
    0)
        is_existing_project
        remove_setup_folder
        setup_existing_project
    ;;

    ## With observer/watcher
    1)
        is_existing_project
        remove_setup_folder
        setup_existing_project
        add_watch_observer
        install_observer
    ;;

    ## Setup tailwind theme
    2)
        is_existing_project
        remove_setup_folder
        setup_tailwind_theme
    ;;

    ## Clean magento2 install
    3)
        setup_clean_magento2_install
        remove_setup_folder
    ;;

    *)
      remove_setup_folder
      exit 1
    ;;
esac


