# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for non-hierarchical relationship mapping
    module NonHierarchicalRelationship
      def special_defaults
        {"relationshiptype" => "affects"}
      end
    end
  end
end
