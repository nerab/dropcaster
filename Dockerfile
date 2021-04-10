FROM ruby:alpine

RUN apk add --no-cache git build-base

# add source code
ADD . /dropcaster
WORKDIR /dropcaster

# install gems
RUN bundle config set --local silence_root_warning 1
RUN bundle config set --local without 'development test'
RUN bundle install --jobs 4

# install it locally
RUN gem install rake
RUN rake --require 'bundler/gem_tasks' install:local

# assume mp3 files mounted to this directory
WORKDIR /public_html

CMD dropcaster
