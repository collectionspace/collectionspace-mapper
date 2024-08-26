# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Checks incoming data before mapping to ensure the necessary data is
    #   present to do the mapping
    class DataValidator
      # @param handler [CollectionSpace::Mapper::DataHandler]
      def initialize(handler)
        @handler = handler
        handler.config.validator = self
        handler.record.extensions.each { |ext| extend ext }

        @id_field = get_id_field
        @required_fields = get_required_fields
        faux_require_id_field
        return if handler.record.service_type == "relation"

        override_based_on_matchpoint if handler.batch.record_matchpoint == "uri"
      end

      def validate(response)
        return response if response.errors?

        check_required_fields(response)
        return response if response.errors?

        special_checks(response)

        response
      end

      private

      attr_reader :handler, :id_field, :required_fields

      def get_id_field
        idfield = handler.record.identifier_field
        fail CollectionSpace::Mapper::IdFieldNotInMapperError if idfield.nil?

        idfield.downcase
      end

      def get_required_fields
        h = {}
        handler.record.mappings
          .required_columns.each do |mapping|
            field = mapping.fieldname.downcase
            column = mapping.datacolumn.downcase
            h.key?(field) ? h[field] << column : h[field] = [column]
          end
        h
      end

      # Adds id_field to @required_fields if not technically required by
      #  application
      def faux_require_id_field
        return if required_fields.key?(id_field)
        return if id_field == "shortidentifier"

        required_fields[id_field] = [id_field]
      end

      def override_based_on_matchpoint
        @required_fields.delete(id_field)
        @id_field = "uri"
        @required_fields["uri"] = ["uri"]
      end

      # @todo The logic of checking should be moved to the *RequiredField
      #   classes
      def check_required_fields(response)
        return response if required_fields.empty?

        data = response.merged_data
        required_fields.each do |field, columns|
          if columns.length == 1
            checkfield = SingleColumnRequiredField.new(field, columns)
            unless checkfield.present_in?(data)
              response.add_error(checkfield.missing_message)
            end
            if checkfield.present_in?(data) && !checkfield.populated_in?(data)
              response.add_error(checkfield.empty_message)
            end
          elsif columns.length > 1
            checkfield = MultiColumnRequiredField.new(field, columns)
            unless checkfield.present_in?(data)
              response.add_error(checkfield.missing_message)
            end
            if checkfield.present_in?(data) && !checkfield.populated_in?(data)
              response.add_error(checkfield.empty_message)
            end
          end
        end
        response
      end

      def special_checks(response)
        response # Actual behavior may be defined in extensions
      end
    end
  end
end
