FROM ruby:2.7.8
COPY config /config
COPY writer /writer
COPY app.rb /
COPY config.ru /
COPY queue_io.rb /
COPY Gemfile /
COPY Gemfile.lock /
RUN bundle install
WORKDIR /
ENV PORT 3000
CMD bundle exec puma -C config/puma.rb