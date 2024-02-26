FROM ruby:2.5.5

RUN wget --no-check-certificate -q -O - https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh > /tmp/wait-for-it.sh \
  && chmod a+x /tmp/wait-for-it.sh

RUN gem install bundler -v '2.2.9'
COPY Gemfile Gemfile.lock ead_indexer.gemspec ./
COPY lib/ead_indexer/version.rb lib/ead_indexer/
RUN bundle install
COPY . ./

CMD [ "bundle", "exec", "rspec" ]
