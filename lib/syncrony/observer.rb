require 'celluloid'
require 'etcd'

module Syncrony
  class Observer

    attr_accessor :running

    def initialize(client, path)
      @client = client
      @path = path
      @running = true
    end

    def run(&handler)
      begin
        info = @client.get(@path)
        value = info.value
        index = info.etcd_index
      rescue Etcd::KeyNotFound
        info = nil
        value = nil
        index = nil
      end

      yield value, @path, info
      
      while @running
        watch = @client.watch(@path, :index => index ? index + 1 : nil)
        if @running
          index = watch.etcd_index
          yield watch.value, @path, watch
        end
      end
    end

    def cancel
      @running = false
    end

  end
end
