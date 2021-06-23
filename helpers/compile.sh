#!/bin/bash

# shellcheck source=./helpers.sh
source "$(dirname "$0")/helpers.sh"

remove_folders() {
  message "Removing: Generated folders.."
  rm -rf var/view_preprocessed/
  rm -rf pub/static/frontend/
  rm -r generated/*/*
  rm -rf pub/static/*
  rm -rf var/generation
  rm -rf var/cache
  rm -rf var/page_cache
}

## Run first time a project need to be build (Local)
if [ "$1" == "deploy" ]; then
  
  message "Enable modules..."
  bin/magento module:enable --all

  message "Disable modules:"
  bash <(curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/modules/disable_modules)

  bin/magento setup:upgrade
  bin/magento setup:static-content:deploy -f
  bin/magento setup:static-content:deploy -f da_DK
  bin/magento setup:di:compile
  bin/magento indexer:reindex
  bin/magento cache:clean
  bin/magento cache:flush
  
  message "Enable Developer mode"
  bin/magento deploy:mode:set developer
  
  message "Deployed"

## Install base repositories
elif [ "$1" == "composer" ]; then
  install_or_update_composer_packages false

## Dump SQL with magerun2
elif [ "$1" == "magerun" ]; then

  MAGE_DIR=./n98-magerun2.phar

  # Don't install if mage is already installed
  if [ ! -f "$MAGE_DIR" ]; then
    wget https://files.magerun.net/n98-magerun2.phar
    chmod +x ./n98-magerun2.phar
  fi

  # Check version (test)
  ./n98-magerun2.phar --version

  ## Export SQL
  # ./n98-magerun2.phar db:dump --strip="@development" # Development
  # n98-magerun2.phar db:dump --compression="gzip" # full-zip

  ## CleanUp: Forget and remove n98-magerun2.phar
  rm -rf ./n98-magerun2.phar

## Rebuild
elif [ "$1" == "rebuild" ]; then

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
elif [ "$1" == "flush_cache" ]; then

  message "Clearing & Flushing files.."
  remove_folders
  bin/magento cache:clean
  bin/magento cache:flush
  message "Finished..."

elif [ "$1" == "tailwind" ]; then

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

  cd /var/www/html/ || exit

  # Clean XML etc
  message "Cache: Clean/Flush.."
  bin/magento cache:clean
  bin/magento cache:flush

  message "Done Compiling"
fi


