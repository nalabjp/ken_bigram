require_relative 'ngram'

module KenBigram
  class Finder
    def initialize(source)
      @source = source
    end

    def find(word)
      bigramize(word).map do |str|
        fetch(str)
      end.compact
    end

    private

    def bigramize(word)

    end

    def fetch(word)
      @source[str]
    end
  end
end
