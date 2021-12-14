module KenBigram
  module Ngram
    class << self
      def bigramize(word)
        ngramize(word, 2)
      end

      private

      def ngramize(word, n_gram)

      end
    end
  end
end
