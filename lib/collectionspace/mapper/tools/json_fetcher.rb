# frozen_string_literal: true

require "net/http"

module CollectionSpace
  module Mapper
    module Tools
      class JsonFetcher
        def self.call(url)
          new(url).call
        end

        def initialize(url)
          @url = URI(url)
        end

        def call
          parse_json(fetch_json_file)
            .transform_keys(&:to_sym)
        end

        private

        attr_reader :url

        def fetch_json_file
          Net::HTTP.get(url)
        rescue => err
          raise CollectionSpace::Mapper::UnfetchableFileError.new(url, err)
        end

        def parse_json(str)
          JSON.parse(str)
        rescue => err
          raise CollectionSpace::Mapper::UnparseableJsonError.new(url, err)
        end
      end
    end
  end
end
