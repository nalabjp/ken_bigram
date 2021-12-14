require_relative 'ken_bigram/data_source'
require_relative 'ken_bigram/finder'
require_relative 'ken_bigram/terminal'

module KenBigram
  class << self
    def generate
      DataSource.generate
    end

    def search
      finder = Finder.new(DataSource.load)
      Terminal.start(finder)
    end
  end
end
