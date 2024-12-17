FROM ruby:2.7.8
COPY config /config
COPY writer /writer
COPY app.rb /
COPY config.ru /
COPY queue_io.rb /
COPY Gemfile /
# Depends on a version of libstdc++ old enough not to be in packages
# Normal deps (install node from distro)
RUN bundle install
WORKDIR /
ENV PORT 3000
CMD ["bundle", "exec puma -C config/puma.rb"]