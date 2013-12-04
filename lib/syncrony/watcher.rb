require 'celluloid'
require 'etcd'

module Syncrony
  class Observer

    attr_accessor :running

    def initialize(client, path, &block)
      @client = client
      @path = path
      @block = block
      @running = true
      watch
    end

    def watch
      info = @client.info(path)
      value = info ? info[:value] : nil
      @index = info ? info[:index] : nil

      yield value, @path, info
      
      while @running
        @client.watch(@path, :index => @index + 1) do |w_value, w_key, w_info|
          if @running
            @index = w_info[:index]
            yield w_value, w_key, w_info
          end
        end
      end
    end

    def cancel
      @running = false
    end

  end
end
