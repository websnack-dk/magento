# Setup Magento2 project with Mutagen &amp; DDEV

Bash script to automatic setup DDEV & Mutagen on an existing Magento2 project.

Script adds:
- Elasticsearch for Docker
- .bash_aliases

### Requirements 
- Magento2 (Existing project)
- Docker Desktop
- DDEV-local installed via Homebrew

---

## Usage

```bash 
curl https://raw.githubusercontent.com/websnack-dk/magento/main/setup.sh | bash
```

--- 

## Shell script

`ddev ssh` into ddev web-container and use commands below. 

```html
---- multiply commands ---- 

magento composer    => Install or upgrade (base) composer packages  
magento deploy      => Enables all modules, except Magento_Csp & Magento_TwoFactorAuth & Runs base setup 
magento rebuild     => Re-compiling all files: Clean, Flush, Upgrade, di:compile & static-content:deploy da_DK  
magento clean       => Compile Clean/Flush & Run static-content:deploy da_DK 
magento tailwind    => Compile css file, remove generated folders & Clean/flush 
magento magerun     => Export SQL via. magerun2 and removes n98-magerun2.phar


---- Magento commands ----

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

### Maintainer

- [Websnack, William](https://websnack.dk)