require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'rubyzip'
end

require_relative 'ken_bigram/data_source'
require_relative 'ken_bigram/finder'
require_relative 'ken_bigram/terminal'

module KenBigram
  class << self
    def generate(update: false)
      DataSource.generate(update: update)
    end

    def search
      finder = Finder.new(DataSource.load)
      Terminal.start(finder)
    end
  end
end
