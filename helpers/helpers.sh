#!/bin/bash

# shellcheck source=./helpers.sh
source "$(dirname "$0")/func.sh"

## Install repositories for BASE-theme
function install_or_update_composer_packages() {

  # Run composer
  message "Cleaning composer..."
  composer clear-cache

  # Install packages for base theme
  # Amasty is required + the packages added in order to install packages 
  composer require magento/data-migration-tool:^2.4.3 amasty/shopby amasty/mega-menu:^1.9 mageplaza/magento-2-danish-language-pack:dev-master avada/module-proofo mageplaza/module-core mageplaza/magento-2-product-slider amasty/module-single-step-checkout amasty/cart

  ## If true: Setup, Upgrade after install ##
  local setUpgrade=$1

  if [ "$setUpgrade" == true ]; then
      message "Setup: Deploy, reindex, clean & flush "
      magerun2 setup:static-content:deploy -f
      magerun2 setup:static-content:deploy da_DK -f
      magerun2 indexer:reindex
      magerun2 setup:upgrade
      magerun2 cache:clean
      magerun2 cache:flush
      message "Setup done"
  fi

    message "Done checking packages"
}
