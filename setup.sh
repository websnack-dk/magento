#!/bin/bash

# from github repo
GITHUB=https://raw.githubusercontent.com/websnack-dk/magento/main/

COLOR_REST="$(tput sgr0)"
COLOR_GREEN="$(tput setaf 2)"
COLOR_RED="$(tput setaf 1)"
COLOR_YELLOW="$(tput setaf 3)"
COLOR_BLUE="$(tput setaf 4)"

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

#
# Automatically configures magento2 project with mutagen sync & DDEV
#

# Copy helper-files into magento bin folder
if [ ! -d "bin" ]; then
    printf '%s\n' "$COLOR_RED [!] Bin folder does not exist. Make sure Magento2 project is installed $COLOR_REST"
    exit 1
fi

# Copy files from github
printf '%s\n' "$COLOR_YELLOW Downloading helper files $COLOR_REST"
curl -s "$GITHUB"helpers/compile.sh --output bin/compile.sh --silent
curl -s "$GITHUB"helpers/helpers.sh --output bin/helpers.sh --silent
curl -s "$GITHUB"helpers/func.sh    --output bin/func.sh    --silent

# make files executable
chmod +x bin/helpers.sh
chmod +x bin/compile.sh
chmod +x bin/func.sh
printf '%s\n' "$COLOR_GREEN Helper files downloaded to bin folder $COLOR_REST"

# Check if DDEV directory exist
if [ ! -d ".ddev" ]; then

  printf '%s\n' "$COLOR_RED [!] .ddev folder does not appear to be in the project. $COLOR_REST"
  sleep 1

  printf '%s\n' "$COLOR_YELLOW Creating .ddev folder $COLOR_REST"
  ddev config --project-type=magento2 --docroot=pub --create-docroot
  printf '%s\n' "$COLOR_GREEN .ddev folder created $COLOR_REST"

  # Create DDEV elasticsearch if not already added
  if [ ! -f ".ddev/docker-compose.elasticsearch.yaml" ]; then
    {
        echo -e "version: '3.6'"
        echo -e "services:"
        echo -e " elasticsearch:"
        echo -e "   container_name: ddev-\${DDEV_SITENAME}-elasticsearch"
        echo -e "   hostname: \${DDEV_SITENAME}-elasticsearch"
        echo -e "   image: elasticsearch:7.10.1"
        echo -e "   ports:"
        echo -e "        - \"9200\""
        echo -e "        - \"9300\""
        echo -e "   environment:"
        echo -e "     - cluster.name=docker-cluster"
        echo -e "     - discovery.type=single-node"
        echo -e "     - bootstrap.memory_lock=true"
        echo -e "     - \"ES_JAVA_OPTS=-Xms512m -Xmx512m\""
        echo -e "     - VIRTUAL_HOST=\$DDEV_HOSTNAME"
        echo -e "     - HTTP_EXPOSE=9200:9200"
        echo -e "     - HTTPS_EXPOSE=9201:9200"
        echo -e "   labels:"
        echo -e "       com.ddev.site-name: \${DDEV_SITENAME}"
        echo -e "       com.ddev.approot: \$DDEV_APPROOT"
        echo -e "   volumes:"
        echo -e "       - elasticsearch:/usr/share/elasticsearch/data"
        echo -e "       - \".:/mnt/ddev_config\""
        echo -e " web:"
        echo -e "   links:"
        echo -e "     - elasticsearch:elasticsearch"
        echo -e "volumes:"
        echo -e "   elasticsearch:"
    } > .ddev/docker-compose.elasticsearch.yaml

    printf '%s\n' "$COLOR_GREEN Docker-compose.elasticsearch.yaml added $COLOR_REST"
  fi


  # Let ddev create some base folders
  ddev start
  sleep 2
  printf '%s\n' "$COLOR_YELLOW Stopping DDEV $COLOR_REST"
  ddev stop

  # Copy aliases file
  if [ ! -f ".ddev/homeadditions/.bash_aliases"  ]; then
    # copy file
    cat .ddev/homeadditions/bash_aliases.example > .ddev/homeadditions/.bash_aliases
    # write to file
    cat >> .ddev/homeadditions/.bash_aliases << 'config'
alias magento="bin/compile.sh"
alias m="bin/magento"
alias composer1="composer self-update --1"
alias composer2="composer self-update --2"
alias mdev="bin/magento deploy:mode:set developer"
alias mclean="bin/magento cache:clean"
alias mflush="bin/magento cache:flush"
alias mdeploy="bin/magento setup:static-content:deploy -f da_DK"
alias mcompile="bin/magento setup:di:compile"
alias mupgrade="bin/magento setup:upgrade"
alias mindexer="bin/magento indexer:reindex"
config
  fi

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

    # Add watch script
    if [ -d "Watcher" ]; then
      curl -s "$GITHUB"Watcher/Watcher.py -o Watcher/Watcher.py --create-dirs
      # make files executable
      chmod +x Watcher/Watcher.py
      printf '%s\n' "$COLOR_GREEN Custom watcher added in Watcher/Watcher.py $COLOR_REST"
    fi

  fi

fi

# Setup Mutagen & Run DDEV
if [ -d ".ddev" ]; then

    # Setup mutagen if not already set
    if [ ! -f ".ddev/commands/host/mutagen" ]; then
      printf '%s\n' "$COLOR_YELLOW Setting up mutagen sync script in current ddev project $COLOR_REST"
      curl https://raw.githubusercontent.com/williamengbjerg/ddev-mutagen/master/setup.sh | bash
    fi

    # Run DDEV project in Docker
    printf '%s\n' "$COLOR_YELLOW Starting ddev project $COLOR_REST"
    ddev start

    printf '%s\n' "$COLOR_GREEN Setup done. Happy coding :) $COLOR_REST"
fi
