FROM ruby
ADD . /dropcaster
WORKDIR /dropcaster
RUN bundle && bundle exec rake
