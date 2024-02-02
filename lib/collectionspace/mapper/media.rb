# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for media mapping
    module Media
      module_function

      def extended(mod)
        if mod.respond_to?(:add_mapping)
          special_mappings(mod).each do |mapping|
            mod.add_mapping(mapping)
          end
        end
      end

      def special_mappings(mod)
        [
          {
            fieldname: "mediaFileURI",
            namespace: mod.handler.record.common_namespace,
            data_type: "string",
            xpath: [],
            required: "n",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: "mediaFileURI",
            transforms: {}
          }
        ]
      end
    end
  end
end
