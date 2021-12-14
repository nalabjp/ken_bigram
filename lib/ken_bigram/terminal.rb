require 'readline'

module KenBigram
  class Terminal
    def self.start(finder)
      new(finder).start
    end

    def initialize(finder)
      @finder = finder
    end

    def start
      while word = Readline.readline("> ", true)
        result = search(word)
        print("-> ", result, "\n")
      end
    end

    private

    def search(word)
      result = @finder.find(word)
      if result.empty?
      else
      end
    end
  end
end
