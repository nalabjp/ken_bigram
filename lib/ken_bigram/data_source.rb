# frozen_string_literal: true
require 'open-uri'
require 'zip'
require 'csv'
require 'set'
require 'yaml'
require_relative 'ngram'

module KenBigram
  class DataSource
    # https://www.post.japanpost.jp/zipcode/dl/readme.html
    KEN_ALL_DOWNLOAD_URL = 'https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'
    DATA_DIR = 'data'
    DOWNLOADED_ZIP_FILE = "#{DATA_DIR}/ken_all.zip"
    KEN_ALL_CSV_FILE = "#{DATA_DIR}/KEN_ALL.CSV"
    INDEX_FILE = "#{DATA_DIR}/ken_bigram.index.yaml"
    DATA_FILE = "#{DATA_DIR}/ken_bigram.data.yaml"

    # CSV
    CSV_HEADERS = [
      'code',
      'zipcode_old',
      'zipcode',
      'prefecture_kana',
      'city_kana',
      'address_kana',
      'prefecture',
      'city',
      'address',
      'ext1',
      'ext2',
      'ext3',
      'ext4',
      'ext5',
      'ext6'
    ].freeze
    CSV::Converters[:utf8] = -> (str) { str.encode(Encoding.default_external) }
    BIGRAMIZE_COLUMNS = [:prefecture, :city, :address].freeze

    # Errors
    NotFoundFile = Class.new(StandardError)

    # Data source
    class Source < Struct.new(:index, :data)
      def initialize(*)
        super
        self.index ||= Hash.new { |h, k| h[k] = Set.new }
        self.data ||= Hash.new { |h, k| h[k] = [] }
      end

      def add_index(key, value)
        index[key].add(value)
      end

      def add_data(key, value)
        # TODO: 重複データ削除、複数行データのマージ等
        #       パターンが色々ありそうなので気が向いたら。。。
        data[key].push(value)
      end

      def fetch_multi(index_key)
        index[index_key]&.map do |data_key|
          format(data[data_key])
        end
      end

      private

      def format(list)
        list.join(',')
      end
    end

    class << self
      def generate(update: false)
        new(update: update).generate
      end

      def load
        new.load
      end
    end

    def initialize(update: false)
      @update = update
    end

    def generate
      prepare if preparable?
      clear
      generate_files
    end

    def load
      raise NotFoundFile, "Not found #{INDEX_FILE} or #{DATA_FILE}" unless exist_files?
      clear
      load_files
      @source
    end

    private

    def preparable?
      @update || !File.exist?(DOWNLOADED_ZIP_FILE)
    end

    def prepare
      mkdir_data
      download
      unzip
      verify!
    end

    def clear
      @csv_table = nil
      @source = Source.new
    end

    def generate_files
      read_csv
      parse
      write_files
    end

    def mkdir_data
      Dir.mkdir(DATA_DIR) unless Dir.exist?(DATA_DIR)
    end

    def download
      File.open(DOWNLOADED_ZIP_FILE, 'wb') do |saved|
        URI.open(KEN_ALL_DOWNLOAD_URL, 'rb') do |f|
          saved.write(f.read)
        end
      end
    end

    def verify!
      raise NotFoundFile, "Not found #{KEN_ALL_CSV_FILE}" unless File.exist?(KEN_ALL_CSV_FILE)
    end

    def unzip
      Zip::File.open(DOWNLOADED_ZIP_FILE) do |zip|
        zip.each { |f| zip.extract(f, "#{DATA_DIR}/#{f.name}") { true } }
      end
    end

    def read_csv
      @csv_table = CSV.read(KEN_ALL_CSV_FILE,
                            encoding: Encoding::SHIFT_JIS,
                            converters: :utf8,
                            headers: CSV_HEADERS,
                            header_converters: :symbol)
    end

    def parse
      @csv_table.each_with_object(@source) do |row, src|
        BIGRAMIZE_COLUMNS.flat_map do |col|
          Ngram.bigramize(row[col]).each do |bigramized|
            src.add_index(bigramized, row[:zipcode])
          end
        end

        src.add_data(row[:zipcode], [row[:zipcode], row[:prefecture], row[:city], row[:address]])
      end
    end

    def write_files
      File.write(INDEX_FILE, @source.index.to_yaml, mode: 'w')
      File.write(DATA_FILE, @source.data.to_yaml, mode: 'w')
    end

    def load_files
      @source.index = YAML.load_file(INDEX_FILE)
      @source.data = YAML.load_file(DATA_FILE)
    end

    def exist_files?
      File.exist?(INDEX_FILE) && File.exist?(DATA_FILE)
    end
  end
end
