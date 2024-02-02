# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for authority mapping
    module Authority
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
            fieldname: "shortIdentifier",
            namespace: mod.handler.record.common_namespace,
            data_type: "string",
            xpath: [],
            required: "not in input data",
            repeats: "n",
            in_repeating_group: "n/a",
            datacolumn: "shortIdentifier",
            transforms: {}
          }
        ]
      end
    end
  end
end
