#  config/initializers/redis.rb
require 'redis'

uri = URI.parse('redis://redis_end_point:6379' || 'localhost:6379')
REDIS = Redis.new(host: uri.host, port: uri.port)