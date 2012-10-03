# POSLavu

[POSLavu](http://www.poslavu.com/) is a hosted point-of-sale system. They
provide an API. This gem consumes that API.

You must have a POSLavu account to do anything useful.

## Installation

Add this line to your application's Gemfile:

    gem 'poslavu'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install poslavu

## Usage

TODO: Write usage instructions here

## Development

Running the suite requires POSLavu API credentials. You can pass in your credentials
using environment variables or by creating a +.env+ file with the following:

    POSLAVU_DATANAME=foobar
    POSLAVU_KEY=q834SCx...
    POSLAVU_TOKEN=EZcWR0n...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
