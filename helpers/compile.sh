#!/bin/bash

# shellcheck source=./helpers.sh
source "$(dirname "$0")/helpers.sh"

remove_folders() {
  message "Removing: Generated folders.."

  find 'generated' -depth -not -name '.htaccess' -not -path 'generated' -type d -exec rm -rf {} \;

  rm -rf var/view_preprocessed/
  rm -rf pub/static/frontend/
  rm -rf var/cache
  rm -rf pub/static/*
  rm -rf var/generation
  rm -rf var/page_cache
}

## Run first time a project need to be build (Local)
if [ "$1" == "deploy" ]; then

  rm -rf generated/*
  rm -rf var/cache/*

  message "Enable modules..."
  bin/magento module:enable --all

  # Disable modules
  message "Disable modules:"
  bash <(curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/modules/disable_modules)

  bin/magento setup:upgrade
  bin/magento setup:static-content:deploy -f
  bin/magento setup:static-content:deploy -f da_DK
  bin/magento setup:di:compile
  bin/magento indexer:reindex
  magerun2 cache:clean
  magerun2 cache:flush

  message "Enable Developer mode"
  bin/magento deploy:mode:set developer

  message "Deployed"

## Install base repositories
elif [ "$1" == "composer" ]; then
  install_or_update_composer_packages false

## Dump SQL with magerun2
elif [ "$1" == "dump-db" ]; then

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
  ./n98-magerun2.phar db:dump --compression="gzip" # full-zip

  ## CleanUp: Forget and remove n98-magerun2.phar
  rm -rf ./n98-magerun2.phar

## Rebuild
elif [ "$1" == "rebuild" ]; then

  # remove generated folders
  remove_folders

  message "Re-Compiling Files.."
  magerun2 cache:clean
  magerun2 cache:flush
  bin/magento setup:upgrade
  bin/magento setup:di:compile
  bin/magento setup:static-content:deploy da_DK --exclude-theme Magento/luma --exclude-theme Magento/blank --force
  message "Files Has Been Re-build"

## Compile LESS-files
elif [ "$1" == "flush_cache" ]; then

  message "Clearing & Flushing files.."
  remove_folders
  magerun2 cache:clean
  magerun2 cache:flush
  message "Finished..."

elif [ "$1" == "tailwind" ]; then

  # remove generated folders
  remove_folders

  # compile tailwindcss
  message "Compiling: Tailwind.."
  cd /var/www/html/app/design/frontend/Theme/base/web/css/tailwind || exit
  npm run build

  cd /var/www/html/ || exit

  # Clean XML etc
  message "Cache: Clean/Flush.."
  magerun2 cache:clean
  magerun2 cache:flush

  message "Done Compiling"
fi


