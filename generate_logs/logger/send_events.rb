# frozen_string_literal: true

require 'json'
require 'logger'
require 'socket'
require 'time'

require 'faker'
require 'fluent-logger'

N = 10_000_000

CONTAINER_IDS = 100.times.map { SecureRandom.hex(32) }
PATHS = %w[/v1/foo /v1/bar /v1/baz]

FLUENTD_HOST = ENV.fetch('FLUENTD_HOST', 'localhost')

$stdout.sync = true
logger = Logger.new($stdout)

begin
  TCPSocket.new(FLUENTD_HOST, 24224).close
rescue Errno::ECONNREFUSED
  logger.info "Waiting for fluentd to start"
  sleep 10
  retry
end

log = Fluent::Logger::FluentLogger.new('docker', host: FLUENTD_HOST, port: 24224, nanosecond_precision: true)

prng = Random.new(42)
Faker::Config.random = prng

logger.info 'Start sending events'

base_time = Time.now.yield_self do |t|
  # Set a future time to prevent flush using time key
  Time.new(t.year, t.month, t.day + 1, 12)
end

delta = Rational(3600, 10_000_000)
N.times do |i|
  now = base_time + delta * i
  event = {
    container_id: CONTAINER_IDS.sample(random: prng),
    container_name: '/test-container',
    source: 'stdout',
    FLUENTD_STDOUT_FILTER_PATTERN: '\A[^ ]* [^ ]* [^ ] \[[^\]]*\] "\S+(?: +[^\"]*?(?: +\S*)?)?" 2',
  }
  if prng.rand(1000).zero?
    event[:log] = %Q|#{Faker::Internet.public_ip_v4_address} - - [#{now.strftime('%d/%b/%Y:%T %z')}] "GET /v2#{PATHS.sample(random: prng)} HTTP/1.1" 404 153 "-" "#{Faker::Internet.user_agent}" "-"|
  else
    event[:log] = %Q|#{Faker::Internet.public_ip_v4_address} - - [#{now.strftime('%d/%b/%Y:%T %z')}] "GET #{PATHS.sample(random: prng)} HTTP/1.1" 200 #{prng.rand(1000) + 100} "-" "#{Faker::Internet.user_agent}" "-"|
  end

  unless log.post_with_time('nginx', event, now)
    logger.error "Failed to send an event: #{log.last_error}"
  end

  if ((i + 1) % 10_000).zero?
    logger.info "#{i + 1} events were sent"
  end
end
logger.info 'Sending events is complete'
