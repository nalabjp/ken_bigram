require_relative 'ngram'

module KenBigram
  class Finder
    def initialize(source)
      @source = source
    end

    def find(word)
      bigramize(remove_whitespace(word)).flat_map do |bigramized|
        fetch(bigramized)
      end.compact
    end

    private

    def remove_whitespace(word)
      word.gsub(/[[:space:]]/, '')
    end

    def bigramize(word)
      Ngram.bigramize(word)
    end

    def fetch(word)
      @source.fetch_multi(word)
    end
  end
end
