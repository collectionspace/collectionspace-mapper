# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for authority mapping
    module Authority
      def special_mappings
        [
          {
            fieldname: "shortIdentifier",
            namespace: CollectionSpace::Mapper.record.common_namespace,
            data_type: "string",
            xpath: [],
            required: "not in input data",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: "shortIdentifier"
          }
        ]
      end
    end
  end
end
