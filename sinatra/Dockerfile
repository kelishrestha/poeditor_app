FROM ruby:2.6.3
RUN apt-get update -qq && \
    apt-get install -y build-essential && \
    useradd ruby
USER ruby
WORKDIR /web
COPY --chown=ruby:ruby Gemfile Gemfile.lock Rakefile config.ru ./
COPY --chown=ruby:ruby config ./config
COPY --chown=ruby:ruby lib ./lib
COPY --chown=ruby:ruby public ./public
COPY --chown=ruby:ruby app ./app
RUN gem install bundler && bundle install

EXPOSE 3000
CMD ["bundle", "exec", "rackup", "config.ru", "-p", "3000", "-s", "thin", "-o", "0.0.0.0"]
