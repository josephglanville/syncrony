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
      info = @client.info(@path)
      value = info ? info[:value] : nil
      index = info ? info[:index] : nil

      yield value, @path, info
      
      while @running
        @client.watch(@path, :index => index ? index + 1 : nil) do |w_value, w_key, w_info|
          if @running
            index = w_info[:index]
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
