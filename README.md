# Setup Magento2 project with Mutagen &amp; DDEV

Bash script to automatic setup DDEV & Mutagen on an existing Magento2 project.

Automatic adds:
- Elasticsearch for Docker
- .bash_aliases

## Requirements 
- [Magento2](https://github.com/magento/magento2) - Only works on existing projects
- [Docker Desktop](https://docs.docker.com/docker-for-mac/apple-m1/) for Apple Silicon. - Only tested on M1.
- [DDEV-local](https://ddev.readthedocs.io/en/stable/) installed via Homebrew

---

## Usage
Paste curl-url in terminal and enjoy.
```bash 
curl https://raw.githubusercontent.com/websnack-dk/magento/main/setup.sh | bash
```
--- 

## Shell helpers
SSH into ddev web-container and use commands below. 

```html
---- multiply commands ---- 

magento composer    => Install or upgrade (base) composer packages  
magento deploy      => Enables all modules, except Magento_Csp & Magento_TwoFactorAuth & Runs base setup 
magento rebuild     => Re-compiling all files: Clean, Flush, Upgrade, di:compile & static-content:deploy da_DK  
magento clean       => Compile Clean/Flush & Run static-content:deploy da_DK 
magento tailwind    => Compile css file, remove generated folders & Clean/flush (Requires some setup in order to work)
magento magerun     => Export SQL via. magerun2 and removes n98-magerun2.phar


---- Magento shortcuts ----

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