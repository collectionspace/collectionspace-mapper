# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module Tools
      module Symbolizable
        extend self

        def symbolize(hash)
          hash.transform_keys{ |key| key.to_sym }
        end

        def symbolize_transforms(transforms)
          transforms.each do |_field, fieldtransform|
            fieldtransform.transform_keys!(&:to_sym)
            next unless replacements?(fieldtransform)

            symbolize_replacements(fieldtransform[:replacements])
          end
        end

        def symbolize_replacements(replacements)
          replacements.map!{ |hash| hash.transform_keys!(&:to_sym) }
        end

        def replacements?(fieldtransform)
          fieldtransform.key?(:replacements)
        end
      end
    end
  end
end
