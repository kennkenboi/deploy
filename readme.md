<div align="center">

# Laravel Deploy

[![ForTheBadge built-with-love](http://ForTheBadge.com/images/badges/built-with-love.svg)](https://twitter.com/kenboi_)

</div>


## Config example:

```
name: Build and Deploy
on:
    push:
        branches:
            -   master

jobs:
    build:
        name: Build and Deploy
        runs-on: ubuntu-latest
        steps:
            -   name: Deploy to Server
                uses: kennkenboi/deploy@v2
                env:
                    DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
                    DEPLOY_USER: ${{ secrets.DEPLOY_USER }}
                    DEPLOY_HOST: ${{ secrets.DEPLOY_HOST }}
                    DEPLOY_PATH: ${{ secrets.DEPLOY_PATH }}
```
