require "metacrunch/redis"

module Metacrunch
  class Redis::QueueWriter

    def initialize(redis_connection_or_url, queue_name, options = {})
      @queue_name = queue_name
      raise ArgumentError, "queue_name must be a string" unless queue_name.is_a?(String)

      @redis = if redis_connection_or_url.is_a?(String)
        ::Redis.new(url: redis_connection_or_url)
      else
        redis_connection_or_url
      end
    end

    def write(data)
      @redis.rpush(@queue_name, data.to_json)
    end

    def close
      @redis.close if @redis
    end

  end
end