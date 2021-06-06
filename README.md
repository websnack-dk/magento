# Single Curl-Command to setup Magento2, Elasticsearch, DDEV & Mutagen.

### Bash script only works on existing Magento2 projects.
#### Setup has only been tested on Apple Silicon M1

---

Requirements will automatically be installed.  
Except Docker Desktop

### Requirements

- [Magento2](https://github.com/magento/magento2) 
- [Docker Desktop](https://docs.docker.com/docker-for-mac/apple-m1/)
- [DDEV-local](https://ddev.readthedocs.io/en/stable/)
    - [Elasticsearch](https://www.elastic.co/)
- [Mutagen](https://mutagen.io/)

---

## Usage
Copy, paste curl-command below and enjoy ☕
```bashpro shell script
curl https://raw.githubusercontent.com/websnack-dk/magento/main/setup.sh | bash
```
--- 

## Helpers
SSH into web-container and use shortcut-commands below

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
mdev                => bin/magento deploy:mode:set developer
mclean              => bin/magento cache:clean
mflush              => bin/magento cache:flush
mdeploy             => bin/magento setup:static-content:deploy -f da_DK
mcompile            => bin/magento setup:di:compile
mupgrade            => bin/magento setup:upgrade
mindexer            => bin/magento indexer:reindex
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
