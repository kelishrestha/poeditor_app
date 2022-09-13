FROM public.ecr.aws/q4w2w1a0/kudo-public:baseimage-v2.6

ENV GEM_HOME /web/.gem
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH

COPY --chown=ruby:ruby Gemfile Gemfile.lock Rakefile config.ru ./
COPY --chown=ruby:ruby config ./config
COPY --chown=ruby:ruby lib ./lib
COPY --chown=ruby:ruby public ./public
COPY --chown=ruby:ruby app ./app
RUN gem install bundler && bundle install

EXPOSE 3000

CMD ["bundle", "exec", "rackup", "config.ru", "-p", "3000", "-s", "thin", "-o", "0.0.0.0"]
