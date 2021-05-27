#!/bin/bash

# shellcheck source=./helpers.sh
source "$(dirname "$0")/helpers.sh"

remove_folders() {
  message "Removing: Generated folders.."
  rm -rf var/view_preprocessed/
  rm -rf pub/static/frontend/
  rm -r generated/*/*
  rm -rf pub/static/*
}

## Run first time a project need to be build (Local)
if [ "$1" = "deploy" ]; then

  # Does .ddev folder exists? No, create folder and run magento2 config setup
  if [ ! -d "../.ddev" ]; then
      ddev config --project-type=magento2 --docroot=pub --create-docroot
      message "DDEV config has been created"
  fi

  # Create DDEV elasticsearch-file if not added
  if [ ! -f "../.ddev/docker-compose.elasticsearch.yaml" ]; then
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

    message "Docker-compose.elasticsearch.yaml Created"
  fi

  # Run Mutagen+Docker (if .ddev folder exist)
  if [ -d "../.ddev" ]; then

      message "Mutagen synchronizing: This could take a while.."
      curl https://raw.githubusercontent.com/williamengbjerg/ddev-mutagen/master/setup.sh | bash
      sleep 120 # sleep while mutagen is synchronizing folder into docker web-container

      # Make sure mutagen daemon is running
      mutagen daemon start
      mutagen daemon register
      sleep 2

      # Run DDEV project in Docker
      message "Running docker setup"
      ddev start
      sleep 120 # sleep while docker is setting up project
  fi

  message "Setup Developer & Enable modules..."
  bin/magento deploy:mode:set developer
  bin/magento module:enable --all

  message "Disable modules:"
  bin/magento module:disable Magento_Csp              # disable module
  bin/magento module:disable Magento_TwoFactorAuth    # disable module

  bin/magento setup:upgrade
  bin/magento setup:static-content:deploy -f
  bin/magento setup:static-content:deploy -f da_DK
  bin/magento setup:di:compile
  bin/magento indexer:reindex
  bin/magento cache:clean
  bin/magento cache:flush
  message "Deployed"

## Install base repositories
elif [ "$1" = "composer" ]; then
  install_or_update_composer_packages false

## Dump SQL with magerun2
elif [ "$1" = "magerun" ]; then

  MAGE_DIR=./n98-magerun2.phar

  # Don't install if mage is already installed
  if [ ! -f "$MAGE_DIR" ]; then
    wget https://files.magerun.net/n98-magerun2.phar
    chmod +x ./n98-magerun2.phar
  fi

  # Check version (test)
  ./n98-magerun2.phar --version

  ## Run SQL-export
  # ./n98-magerun2.phar db:dump --strip="@development"

  ## Clean up: Forget and remove n98-magerun2.phar
  rm -rf ./n98-magerun2.phar

## Rebuild: Usually used on PROD
elif [ "$1" = "rebuild" ]; then

  # remove generated folders
  remove_folders

  message "Re-Compiling Files.."
  bin/magento cache:clean
  bin/magento cache:flush
  bin/magento setup:upgrade
  bin/magento setup:di:compile
  bin/magento setup:static-content:deploy -f
  bin/magento setup:static-content:deploy -f da_DK
  message "Files Has Been Re-build"

## Compile LESS-files
elif [ "$1" = "tailwind" ]; then

  # remove generated folders
  remove_folders

  # Compile LESS files
  # message "Compiling: Gulp Exec.."
  # gulp exec --base

  # Compile LESS files
  # message "Compiling: Gulp LESS.."
  # gulp less --base

  # compile tailwindcss
  message "Compiling: Tailwind.."
  cd /var/www/html/app/design/frontend/Kommerce/base/web/css/tailwind || exit
  npm run build
  sleep 1
  # npx tailwindcss-cli@latest build app/design/frontend/Kommerce/base/web/css/tailwind/tailwind_source.css -o app/design/frontend/Kommerce/base/web/css/tailwind.css

  cd /var/www/html/ || exit

  # Clean XML etc
  message "Cache: Clean/Flush.."
  bin/magento cache:clean
  bin/magento cache:flush

  message "Done Compiling"
fi
