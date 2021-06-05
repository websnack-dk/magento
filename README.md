# Setup Magento2 project with DDEV & Mutagen 

Bash script only works on existing Magento2 projects. Requiments below will automatic be installed. Except Docker Desktop.

The setup has only been tested on Apple Silicon M1.

## Requirements 

- [Magento2](https://github.com/magento/magento2) 
- [Docker Desktop](https://docs.docker.com/docker-for-mac/apple-m1/)
- [DDEV-local](https://ddev.readthedocs.io/en/stable/)
    - [Elasticsearch](https://www.elastic.co/)
- [Mutagen](https://mutagen.io/)

---

## Usage
Cd into an existing magento2 project from term. Copy, paste curl-command below and enjoy ☕
```bash
curl https://raw.githubusercontent.com/websnack-dk/magento/main/setup.sh | bash
```
--- 

## Helpers
SSH into web-container and use shortcut-commands below

```text
---- Custom commands ---- 

magento composer    => Install or upgrade (base) composer packages  
magento deploy      => Enables all modules, except Magento_Csp & Magento_TwoFactorAuth & Runs base setup 
magento rebuild     => Re-compiling all files: Clean, Flush, Upgrade, di:compile & static-content:deploy da_DK  
magento clean       => Compile Clean/Flush & Run static-content:deploy da_DK 
magento tailwind    => Compile css file, remove generated folders & Clean/flush (Requires tailwind setup in order to work)
magento magerun     => Export SQL via. magerun2 and removes n98-magerun2.phar


---- Base Magento2 Shortcuts ----

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
  
Change file observers in `Watcher/Watcher.py`.  
Standard observation files `.phtml` files in `app/frontend/design/Magento_Theme`

```bash
cd Watcher/
source venv/bin/activate
```

Observe files
```bash
python Watcher.p
```

---

### Maintainer

- [Websnack, William](https://websnack.dk)
