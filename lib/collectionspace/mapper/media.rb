# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for media mapping
    module Media
      def special_mappings
        [
          {
            fieldname: "mediaFileURI",
            namespace: @config.common_namespace,
            data_type: "string",
            xpath: [],
            required: "n",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: "mediaFileURI"
          }
        ]
      end
    end
  end
end
