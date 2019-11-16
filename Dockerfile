FROM ubuntu:18.04

RUN apt update
RUN apt install -y ruby ruby-dev ruby-bundler
RUN apt install -y build-essential zlib1g-dev

ADD ./lib /app

WORKDIR /app

RUN bundler install --path vendor/bundle

CMD ["bundler", "exec", "./a101.rb"]
