# Syncrony

Syncrony is a set of distributed systems primitives built with Celluloid and Etcd.

## Installation

Add this line to your application's Gemfile:

    gem 'syncrony'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install syncrony

## Usage

### Observer
The Observer is a simple primitive that allows you to execute a block every time a key changes in etcd.
Upon calling Observer.run callback will be executed immediately and every time thereafter they key changes.

```ruby
require 'syncrony'
require 'etcd'
client = Etcd::Client.new
client.connect
obs = Syncrony::Observer.new(client, 'test_key')
obs.run do |value, key, info|
  puts value, key, info
end
```

### Election
Election is a higher level primitive that implements basic leader election.
The initial call to Election.run will block until we become the leader, at which point it will then run in the background.
We can step down or cancel leader election by running Election.cancel.

```ruby
require 'syncrony'

election = Syncrony::Election.new(:path => 'test_key')
election.run
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
