FROM ruby:2.6.3
RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN gem install bundler && bundle install

ADD . /app/

EXPOSE 3000
CMD ["bundle", "exec", "rackup", "config.ru", "-p", "3000", "-s", "thin", "-o", "0.0.0.0"]
