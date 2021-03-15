require "redis"

class RedisSupplier
  @@redis = nil
  def self.get
    if @@redis.nil?
      puts "new redis"
      @@redis = Redis.new
      return @@redis
    end

    return @@redis
  end
end