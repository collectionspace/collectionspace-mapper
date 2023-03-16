# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # special behavior for object hierarchy mapping
    module ObjectHierarchy
      def special_defaults
        {"subjectdocumenttype" => "collectionobjects",
         "relationshiptype" => "hasBroader",
         "objectdocumenttype" => "collectionobjects"}
      end
    end
  end
end
