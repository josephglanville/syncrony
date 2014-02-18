require 'syncrony'
require 'celluloid'
require 'etcd'
require 'securerandom'

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
      @identifier = options[:identifier] || SecureRandom.uuid
    end

    def run
      @client = Etcd::Client.new(:uris => @servers)
      @client.connect
      @is_leader = false
      request_election
      return
    end

    def become_leader
      @is_leader = true
      @timer = every(@interval) do
        update
      end
    end

    # Stop being leader, or stop trying to become leader.
    def cancel
      @observer.cancel if @observer
      # TODO race cdn here? Depends how Celluloid works. What if we're in the moddible of becoming leader?
      if @is_leader
        @timer.cancel
        @is_leader = false
        @client.delete(@path)
      end
      return
    end

    def request_election
      @observer = Syncrony::Observer.new(@client, @path)
      @observer.run do |value, path, info|
        if value.nil?
          if @client.set(@path, @identifier, :prevValue => nil, :ttl => @ttl)
            @observer.cancel
            become_leader
          end
        end
      end
    end

    def update
      @client.set(@path, @identifier, :prevValue => @identifier, :ttl => @ttl)
    end

  end
end
