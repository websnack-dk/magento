#!/bin/bash

YELLOW="33"
BOLD_YELLOW="\e[1;${YELLOW}m"
END_COLOR="\e[0m"

# Output message
function message() {
  message=$1
  echo -e "${BOLD_YELLOW} ${message} ${END_COLOR}";
}

#
# Automatically configures magento2 project with mutagen sync & DDEV
#

# Copy helper files into magento bin folder
# Stop process if directory doesn't exist
if [ ! -d "bin" ]; then
  message -e "[!] Folder [bin] does not exist. Make sure Magento2 project is installed"
  exit 1
else
  message "Downloading helper files"
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/compile.sh > bin/compile.sh
  curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/helpers/helpers.sh > bin/helpers.sh
  # make files executable
  chmod +x bin/helpers && chmod +x bin/compile
  message "Helper files downloaded to bin folder"
fi

# Check if DDEV directory exist
if [ ! -d ".ddev" ]; then
  message "[!] DDEV folder does not appear to be in the project."

  # Prompt for auto install
  read -r -p "Do you want me to install .ddev? (y/n)" answer
  case ${answer:0:1} in
    y|Y|Yes )
        ddev config --project-type=magento2 --docroot=pub --create-docroot
        message ".ddev folder created"
    ;;
    * )
        exit 1
    ;;
  esac


  # Copy aliases file
  if [ ! -f ".ddev/homeadditions/.bash_aliases"  ]; then
    cp -v .ddev/homeadditions/bash_aliases.example .bash_aliases

    echo -e "alias magento={bin/compile.sh}"
    echo -e "alias m={bin/magento}"
    echo -e "alias composer1={composer self-update --1}"
    echo -e "alias composer2={composer self-update --2}"
  fi

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

    message "Docker-compose.elasticsearch.yaml added"
  fi
fi

# Setup Mutagen
if [ -d ".ddev" ]; then

    # check if mutagen is installed
    if [ ! -f ".ddev/commands/host/mutagen" ]; then
      message "Setting up mutagen sync script in current ddev project"
      curl https://raw.githubusercontent.com/williamengbjerg/ddev-mutagen/master/setup.sh | bash
    fi

    # Run DDEV project in Docker
    message "Running docker setup"
    ddev start
fi

