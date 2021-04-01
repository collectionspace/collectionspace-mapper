# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class RequiredField
      def initialize(fieldname, datacolumns)
        @field = fieldname.downcase
        @columns = datacolumns.map(&:downcase)
      end

      def present_in?(data)
        present = data.keys.map(&:downcase) & @columns
        present.empty? ? false : true
      end

      def populated_in?(data)
        data = data.transform_keys(&:downcase)
        values = @columns.map{ |column| data[column] }.reject(&:blank?)
        values.empty? ? false : true
      end
    end

    class SingleColumnRequiredField < RequiredField
      def initialize(fieldname, datacolumns)
        super
      end

      def present_in?(data)
        super
      end

      def populated_in?(data)
        super
      end

      def missing_message
        "required field missing: #{@columns[0]} must be present"
      end

      def empty_message
        "required field empty: #{@columns[0]} must be populated"
      end
    end

    class MultiColumnRequiredField < RequiredField
      def initialize(fieldname, datacolumns)
        super
      end

      def present_in?(data)
        super
      end

      def populated_in?(data)
        super
      end

      def missing_message
        "required field missing: #{@field}. At least one of the following fields must be present: #{@columns.join(', ')}"
      end

      def empty_message
        "required field empty: #{@field}. At least one of the following fields must be populated: #{@columns.join(', ')}"
      end
    end

    class DataValidator
      class IdFieldNotInMapperError < StandardError; end
      
      attr_reader :mapper, :cache, :required_fields
      def initialize(record_mapper, cache)
        @mapper = record_mapper
        @cache = cache
        @required_mappings = @mapper.mappings.required_columns
        @required_fields = get_required_fields
        @id_field = get_id_field
        # faux-require ID field for batch processing if it is not technically required by application
        unless @required_fields.key?(@id_field) || @id_field == 'shortidentifier'
          @required_fields[@id_field] = [@id_field]
        end
      end

      def validate(data)
        response = CollectionSpace::Mapper::setup_data(data)
        if response.valid?
          data = response.merged_data.transform_keys!(&:downcase)
          res = check_required_fields(data) unless @required_fields.empty?
          response.errors << res
          response.errors = response.errors.flatten.compact
          response
        else
          response
        end
      end
      
      private

      def get_id_field
        idfield = @mapper.config.identifier_field
        raise IdFieldNotInMapperError if idfield.nil?
        idfield.nil? ? nil : idfield.downcase
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
          binding.pry if field == 'currentlocationlocal'
          if columns.length == 1
            checkfield = SingleColumnRequiredField.new(field, columns)
            errs << checkfield.missing_message if !checkfield.present_in?(data)
            errs << checkfield.empty_message if checkfield.present_in?(data) && !checkfield.populated_in?(data)
          elsif columns.length > 1
            checkfield = MultiColumnRequiredField.new(field, columns)
            errs << checkfield.missing_message if !checkfield.present_in?(data)
            errs << checkfield.empty_message if checkfield.present_in?(data) && !checkfield.populated_in?(data)
          end
        end
        errs
      end
    end
  end
end

