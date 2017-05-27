# Libblacklist

A Ruby interface to NetBSD/FreeBSD's [libblacklist][1], a library for interacting
with [blacklistd][2] - a daemon for blocking abusive clients from servers.

Currently considered EXPERIMENTAL.  Beware of dog, slippery when wet, avoid contact with eyes.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'libblacklist', git: 'https://github.com/Freaky/ruby-libblacklist'
```

And then execute:

    $ bundle


## Usage

The basic premise is something along the lines of:

```ruby
blacklist = BlacklistD.new
server = TCPSocket.new(...)

loop do
  begin
    client = server.accept
    if authenticate(client)
      blacklist.auth_ok(client)
    else
      blacklist.auth_fail(client)
    end

    # ...
  rescue DidSomethingNaughtyError
    blacklist.abusive(client)
  end
end
```

blacklistd will then apply the configured rules for the server to determine whether
the client should be blocked by the system firewall.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Freaky/ruby-libblacklist.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[1]: https://www.freebsd.org/cgi/man.cgi?query=libblacklist&sektion=3&manpath=freebsd-release-ports
[2]: https://www.freebsd.org/cgi/man.cgi?query=blacklistd&sektion=8&manpath=freebsd-release-ports
