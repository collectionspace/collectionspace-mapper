# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for media mapping
    module Media
      def extended(mod)
        puts "#{mod} extended with #{self.name}"
      end

      def special_mappings
        [
          {
            fieldname: "mediaFileURI",
            namespace: CollectionSpace::Mapper.record.common_namespace,
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
