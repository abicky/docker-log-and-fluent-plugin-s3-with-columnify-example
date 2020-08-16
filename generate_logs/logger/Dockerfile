FROM ruby:2.7.1

COPY Gemfile Gemfile.lock ./
RUN bundle install -j4

COPY send_events.rb ./

CMD ["bundle", "exec", "ruby", "send_events.rb"]
