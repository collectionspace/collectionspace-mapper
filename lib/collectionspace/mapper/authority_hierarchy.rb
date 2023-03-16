# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for authority hierarchy mapping
    module AuthorityHierarchy
      def special_defaults
        {"relationshiptype" => "hasBroader"}
      end
    end
  end
end
