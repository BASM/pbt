# Pbt
Parking bot

# Install

On Ubuntu:
* sudo apt install ruby ruby-dev ruby-bundler build-essential zlib1g-dev
* cd lib

Install requirements:
* bundler install --path vendor/bundle

or
* make install

# Usage

Change dir to lib and run script:
* cd lib
* make

or
* bundler exec ./a101.rb

or using docker:
```
docker build . -t pbt
docker run --rm -it pbt
```

# About

origin uri: https://github.com/BASM/pbt
