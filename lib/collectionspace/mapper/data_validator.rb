# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Checks incoming data before mapping to ensure the necessary data is
    #   present to do the mapping
    class DataValidator
      attr_reader :required_fields

      # @todo appconfig remove record_mapper, cache arguments
      def initialize
        @id_field = get_id_field
        @required_mappings = CollectionSpace::Mapper.record.mappings
          .required_columns
        @required_fields = get_required_fields
        # faux-require ID field for batch processing if it is not technically
        #   required by application
        unless @required_fields.key?(@id_field) ||
            @id_field == "shortidentifier"
          @required_fields[@id_field] = [@id_field]
        end
      end

      def validate(response)
        if response.errors.empty?
          data = response.merged_data
          res = check_required_fields(data) unless @required_fields.empty?
          response.add_error(res)
        end
        response
      end

      private

      def get_id_field
        idfield = CollectionSpace::Mapper.record.identifier_field
        fail CollectionSpace::Mapper::IdFieldNotInMapperError if idfield.nil?

        idfield.downcase
      end

      def get_required_fields
        h = {}
        @required_mappings.each do |mapping|
          field = mapping.fieldname.downcase
          column = mapping.datacolumn.downcase
          h.key?(field) ? h[field] << column : h[field] = [column]
        end
        h
      end

      def check_required_fields(data)
        errs = []
        @required_fields.each do |field, columns|
          if columns.length == 1
            checkfield = SingleColumnRequiredField.new(field, columns)
            unless checkfield.present_in?(data)
              errs << checkfield.missing_message
            end
            if checkfield.present_in?(data) && !checkfield.populated_in?(data)
              errs << checkfield.empty_message
            end
          elsif columns.length > 1
            checkfield = MultiColumnRequiredField.new(field, columns)
            unless checkfield.present_in?(data)
              errs << checkfield.missing_message
            end
            if checkfield.present_in?(data) && !checkfield.populated_in?(data)
              errs << checkfield.empty_message
            end
          end
        end
        errs
      end
    end
  end
end
