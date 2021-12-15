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
        begin
          result = search(word)
          print_result(result)
        rescue
          output('An unexpected error has occurred...')
        end
      end
    end

    private

    def search(word)
      @finder.find(word)
    end

    def print_result(result)
      if result.empty?
        output("Not found...")
      else
        result.each { |res| output(res) }
      end
    end

    def output(text)
      $stdout.puts(text)
    end
  end
end
