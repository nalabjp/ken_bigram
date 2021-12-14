require_relative 'ngram'

module KenBigram
  class DataSource
    SOURCE_PATH = ''.freeze

    class Source < Hash; end

    class << self
      def generate
        new.generate
      end

      def load
        new.load
      end

      def exist?
        File.exist?(DataSource::SOURCE_PATH)
      end
    end

    def generate
      prepare
      parse
      write
    end

    def load

    end

    private

    def prepare
      download
      verify!
      unzip
      read
    end

    def download

    end

    def verify!

    end

    def unzip

    end

    def read

    end

    def parse

    end

    def write

    end
  end
end
