require 'syncrony'
require 'celluloid'
require 'etcd'
require 'securerandom'

module Syncrony
  class Lock

    attr_accessor :held
    finalizer :_release

    DEFAULT_OPTS = {
      server: { host: '127.0.0.1', port: 4001 },
      ttl: 15,
      interval: 5
    }

    def initialize(options={})
      options = DEFAULT_OPTS.merge(options)
      raise if not options[:path]

      @path = options[:path]
      @client = Etcd.client(options[:server])
      @ttl = options[:ttl]
      @interval = options[:interval]
      @identifier = options[:identifier] || SecureRandom.uuid

      @refresh_task = nil
      @held = false
    end

    def with(&block)
      acquire
      yield
      release
    end

    def acquire
      raise if @held
      acquired = Celluloid::Condition.new
      watch = Syncrony::Observer.new(@client, @path)
      watch.run do |value, path, info|
        if value.nil?
          begin
            @client.set(@path, value: @identifer, prevExist: false, ttl: @ttl)
            watch.cancel
            acquired.signal(true)
          rescue Etcd::NodeExist
          end
        end
      end
      acquired.wait()
      @held = true
      @refresh_task = Celluloid::every(@interval) do
        begin
          @client.set(@path, value: @identifier, prevValue: @identifier, ttl: @ttl)
        rescue Etcd::KeyNotFound, Etcd::TestFailed
          @held = false
          @refresh_task.cancel 
        end
      end
    end

    # returns true if lock was still held at release, else false
    def release
      was_held = @held
      @refresh_task.cancel unless @refresh_task.nil?
      begin
        @client.delete(@path, prevValue: @identifer)
      rescue Etcd::TestFailed
        was_held = false
      end
      @held = false
      was_held
    end
  end
end
