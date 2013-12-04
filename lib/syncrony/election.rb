require 'celluloid'
require 'etcd'

module Syncrony
  class Election
    include Celluloid

    attr_accessor :is_leader

    DEFAULT_OPTS = {
      :servers => ["127.0.0.1:4001"],
      :ttl => 15,
      :interval => 5,
    }

    def initialize(options={})
      options = DEFAULT_OPTS.merge(options)
      raise if not options[:path]
      @path = options[:path]
      @ttl = options[:ttl]
      @interval = options[:interval]
    end

    def run
      @client = Etcd::Client.new(:uris => @servers)
      @client.connect
      @is_leader = false
      request_election
    end

    def leader_duties
      @timer = every(@interval) do
        update
      end
    end

    def step_down
      @timer.cancel
      @is_leader = false
    end

    def request_election
      puts "request election"
      @sentinel = Time.now.to_i
      if @client.update(@path, @sentinel, nil, :ttl => @ttl)
        return true
      else
        
      end
      @is_leader = @client.update(@path, @sentinel, nil, :ttl => @ttl)
    end

    def update
      puts "update"
      new_sentinel = Time.now.to_i
      if @client.update(@path, new_sentinel, @sentinel, :ttl => @ttl)
        @sentinel = new_sentinel
      else
        raise
      end
    end

  end
end
