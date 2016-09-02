# Terrenv

Terraform has an assumption that your infrastructure would only be deployed
once. But what if you wanted a staging or testing environment? You would have
to manage state files and variable files yourself in different directories.

Terrenv is a simple tool that lets you switch environments seemlessly.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'terrenv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install terrenv

## Usage

Run

    $ terrenv init

and follow the instructions to generate a TerraformFile

## Commands

    $ terrenv init

will ask you some questions to setup your TerraformFile. You will need to run
`terrenv apply` inorder to apply the settings.


    $ terrenv apply

will take the configuration in the TerraformFile does a few steps for setup

1. Create directories for each environment labeled `terraform-<environment>`.
2. Setup your remote state-file configurations and pull down the state files from
   the S3 bucket and placed inside `terraform-<environment>`
3. Sets up your environment to the last environment specified on the TerraformFile


    $ terrenv use <environment>

will switch the symlinks to point to the environment specified.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/terrenv. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

