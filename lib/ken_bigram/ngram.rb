module KenBigram
  module Ngram
    class << self
      def bigramize(word)
        ngramize(word, 2)
      end

      private

      def ngramize(word, size)
        word.each_char.each_cons(size).map(&:join)
      end
    end
  end
end
