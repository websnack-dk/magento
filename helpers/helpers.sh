#!/bin/bash

# shellcheck source=./helpers.sh
source "$(dirname "$0")/func.sh"

## Install repositories for BASE-theme
function install_or_update_composer_packages() {

  # Run composer
  message "Cleaning composer..."
  composer clear-cache

  # Install packages
  composer require mageplaza/magento-2-danish-language-pack:dev-master
  composer require mailchimp/mc-magento2
  composer require bambora/module-payment-magento2
  composer require amasty/mega-menu
  composer require tric/module-autocity
  composer require tric/module-economic
  composer require tric/module-postnord
  composer require tric/module-eanpayment

  # Install Magento2 Gulp
  composer require --dev bobmotor/magento-2-gulp

  # For debug
  composer require spatie/ray

  ## If true: Setup, Upgrade after install ##
  local setUpgrade=$1

  if [ "$setUpgrade" == true ]; then
      message "Setup: Deploy, reindex, clean & flush "
      bin/magento setup:static-content:deploy -f
      bin/magento setup:static-content:deploy da_DK -f
      bin/magento indexer:reindex
      bin/magento setup:upgrade
      bin/magento cache:clean
      bin/magento cache:flush
      message "Setup done"
  fi

    message "Done checking packages"
}
