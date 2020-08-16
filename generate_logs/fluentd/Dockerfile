FROM alpine:3.9 AS builder

RUN apk --no-cache --update add build-base lzo-dev \
  && cd /tmp \
  && wget https://www.lzop.org/download/lzop-1.04.tar.gz \
  && tar xf lzop-1.04.tar.gz \
  && cd ./lzop-1.04 \
  && ./configure \
  && make

FROM fluent/fluentd:v1.11.2-1.0

USER root

RUN apk --no-cache --update add ruby-json lzo-dev \
 && wget https://github.com/reproio/columnify/releases/download/v0.1.0/columnify_0.1.0_Linux_x86_64.tar.gz \
 && tar xf columnify_0.1.0_Linux_x86_64.tar.gz \
 && rm LICENSE README.md columnify_0.1.0_Linux_x86_64.tar.gz \
 && mv columnify /usr/local/bin/

COPY --from=builder /tmp/lzop-1.04/src/lzop /usr/local/bin/

COPY Gemfile* ./
RUN gem install bundler \
  && bundle install -j4 \
  && rm -rf /usr/lib/ruby/gems/*/cache/*.gem

COPY fluent.conf.erb /fluentd/etc/
COPY entrypoint.sh /bin/
RUN mkdir -p /fluentd/avsc
COPY docker_log.avsc /fluentd/avsc/
RUN chown -R fluent /fluentd

RUN wget -P /usr/lib/ruby/gems/2.5.0/gems/fluent-plugin-s3-1.4.0/lib/fluent/plugin/ https://raw.githubusercontent.com/okkez/fluent-plugin-s3/add-parquet-compressor/lib/fluent/plugin/s3_compressor_parquet.rb

USER fluent

CMD ["bundle", "exec", "fluentd", "-c", "/fluentd/etc/fluent.conf"]
