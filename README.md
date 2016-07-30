# mruby-hashie

[Hashie](https://github.com/intridea/hashie) for mruby.

## Installation

Add this line to build\_config.rb:

```ruby
MRuby::Build.new do |conf|
  conf.gem github: 'k0kubun/mruby-hashie'
end
```

or add this line to your application's mrbgem.rake:

```ruby
MRuby::Gem::Specification.new('your-mrbgem') do |spec|
  spec.add_dependency 'mruby-hashie', github: 'k0kubun/mruby-hashie'
end
```

## Usage

Currently mruby-hashie has only `Hashie::Mash` its base `Hashie::Hash`.  
See [intridea/hashie#mash](https://github.com/intridea/hashie#mash) for detail.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/k0kubun/mruby-hashie.

## License

Copyright (c) 2009-2014 Intridea, Inc. (http://intridea.com/) and contributors.

MIT License. See [LICENSE.txt](LICENSE.txt) for details.
