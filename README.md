![GitHub release (latest by date)](https://img.shields.io/github/v/release/websnack-dk/magento?color=blue) ![https://github.com/websnack-dk/magento/graphs/commit-activity](https://img.shields.io/badge/maintained-yes-green)


# Script to setup an existing/or- a clean Magento2 installation with DDEV-local.

Only tested on Apple Silicon M1  
Requirements will automatically be installed, except Docker Desktop.

### Requirements

- [Docker Desktop](https://docs.docker.com/docker-for-mac/apple-m1/)
- [DDEV-local](https://ddev.readthedocs.io/en/stable/)
    - [Elasticsearch](https://www.elastic.co/)
- [Mutagen](https://mutagen.io/)

---

## Usage
Copy/paste curl-command in an existing or empty project folder and enjoy magento2 ☕
```bashpro shell script
bash <(curl -s https://raw.githubusercontent.com/websnack-dk/magento/main/setup.sh)
```

Installing a clean magento2 project requires **Access Keys** (public/private) from [marketplace.magento.com](https://marketplace.magento.com/)

--- 

## Helpers
`ddev ssh` into web-container and use shortcut-commands.

```bashpro shell script
# ---- Custom commands ---- 

magento composer    => Install or upgrade (base) composer packages  
magento deploy      => Enables all modules, except Magento_Csp & Magento_TwoFactorAuth & Runs base setup 
magento rebuild     => Re-compiling all files: Clean, Flush, Upgrade, di:compile & static-content:deploy da_DK  
magento clean       => Compile Clean/Flush & Run static-content:deploy da_DK 
magento tailwind    => Compile css file, remove generated folders & Clean/flush (Requires tailwind setup in order to work)
magento magerun     => Export SQL via. magerun2 and removes n98-magerun2.phar


# ---- Base Magento2 Shortcuts ----

m                   => bin/magento 
composer1           => composer self-update --1
composer2           => composer self-update --2
composerup          => composer update
updatephp           => update-alternatives --config php
mdev                => bin/magento deploy:mode:set developer
mclean              => bin/magento cache:clean
mflush              => bin/magento cache:flush
mdeploy             => bin/magento setup:static-content:deploy -f da_DK && bin/magento setup:static-content:deploy -f da_DK
mcompile            => bin/magento setup:di:compile
mupgrade            => bin/magento setup:upgrade
mindexer            => bin/magento indexer:reindex
mcron               => bin/magento cron:run
```

---

## Observe file changes
  
Standard observation files `.phtml` files in `app/frontend/design/Magento_Theme/templates/html`

Observe files:  
Use an external term for watcher. `ddev ssh` to Watcher-folder.   

```bashpro shell script
cd Watcher/ && source venv/bin/activate && python3 -m pip install watchdog
```

```bashpro shell script
python Watcher.py
```
Change file observers in `Watcher/Watcher.py`

---

### Maintainer

- [Websnack, William](https://websnack.dk)
