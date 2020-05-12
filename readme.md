<div align="center">

# Laravel Deploy

[![ForTheBadge built-with-love](http://ForTheBadge.com/images/badges/built-with-love.svg)](https://ngocquyhoang.com)
[![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)](https://ngocquyhoang.com)
[![forthebadge](https://forthebadge.com/images/badges/powered-by-water.svg)](https://ngocquyhoang.com)

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
            -   name: Checkout Repository
                uses: actions/checkout@master
            -   name: Deploy to Server
                uses: kennkenboi/deploy@master
                env:
                    DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
                    USER: ${{ secrets.USER }}
                    HOST: ${{ secrets.HOST }}
                    PATH: ${{ secrets.PATH }}
```
