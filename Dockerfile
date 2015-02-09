FROM phusion/passenger-ruby22:0.9.15
ADD . /dropcaster
WORKDIR /dropcaster
RUN bundle && bundle exec rake
