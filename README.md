# K-Configurable

Make your classes configurable with this nifty little gem. Instead of
implementing this over and over again, or copying it over and over again into
every project where I need this, I decided to extract this tiny gem.
Feel free to use it.

There are other gems that do something similiar with a different syntax, e.g.:

1. [dry-configurable](https://github.com/dry-rb/dry-configurable)
2. [Configurable](https://github.com/thinkerbot/configurable)
3. [simply_configurable](https://github.com/daws/simply_configurable)
4. [ruby-configurable](https://bitbucket.org/krbullock/configurable)
5. [block_configurable](https://github.com/artemshitov/block_configurable)

Without have looked too much at those, dry-configurable is probably the best
choice since the guys over at dry have quite a few mini gems they maintain and
use. Also, there are many, many more than those up there.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'k-configurable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install k-configurable

## Usage

Include the `K::Configurable` module in the class definition body of the class
you would like to make configurable. For example, maybe you need to wrap a
database connection with an adapter:

```
class DatabaseAdapter
  # make host, port, user and password configurable
  include K::Configurable[:host, :port, :user, :password]
  
  # ...
  
  # use configurable attributes to open a connection
  # which may look something like this:
  def connection
    config = self.class.configuration
    Connection.open(
      "#{config.user}:#{config.password}@#{config.host}:#{config.port}"
    )
  end
end

# configure it
DatabaseAdapter.configure do |config|
  config.host = 'localhost'
  config.port = '12345'
  config.user = 'foo'
  config.password = File.read('/run/secrets/dbpassword')
end
```

The configuration attributes are accessible via the `configuration` class method
since I don't want them to pollute the class interface. If you however find it
tedious to always have to refer to `configuration` and don't mind having those
attribute setter and getter methods on your classes interface, then simply add
some forwardables like this:

```
class DatabaseAdapter
  include K::Configurable[:host, :port, :user, :password]
  extend SingleForwardable
  def_single_delegators :configuration, :host, :port, :user, :password
end
```

Be careful about name collisions though. E.g., `name` would be a very bad
attribute to delegate.

### Configurable with Defaults

You can specify defaults like this:

```
class DatabaseAdapter
  include K::Configurable[:user, :password, host: 'localhost', port: 12345]
end
```

Defaults are implemented using named parameters, therefore you have to mind all
the same rules you do when invoking any method in Ruby. I.e., you cannot mix
named parameters and normal parameters, they have to be strictly ordered, normal
parameters first, then named parameters.

### Define methods on configuration

** Do NOT use **

It is possible to define methods during configuration definition, however, I do
not like the way it is implemented and really have used it only in one instance
yet. So use at own risk it may change without further notice. If you absolutely
want to use it, it is at your own risk.. See the tests on how it works.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kaikuchn/configurable.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

