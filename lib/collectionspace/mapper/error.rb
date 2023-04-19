# frozen_string_literal: true

module CollectionSpace
  module Mapper
    # Mixin module included in any application-specific error classes
    #
    # This allows each application-specific error to:
    #
    # - be subclassed to proper exception class in standard Ruby exception
    #   hierarchy
    # - be identified or rescued by standard Ruby exception
    #   hierarchy ancestor, OR by application-specific error status
    module Error
      # Placeholder
    end

    class ConfigKeyMissingError < StandardError
      include CollectionSpace::Mapper::Error

      attr_reader :keys

      def initialize(keys)
        @keys = keys
      end
    end

    class UnhandledConfigFormatError < StandardError
      include CollectionSpace::Mapper::Error
    end

    class IdFieldNotInMapperError < StandardError
      include CollectionSpace::Mapper::Error
    end

    class MultipleCsRecordsFoundError < StandardError
      include CollectionSpace::Mapper::Error

      def initialize(count)
        msg = "#{count} matching records found in CollectionSpace. "\
          "Cannot determine which to update."
        super(msg)
      end
    end

    class NoClientServiceError < StandardError
      include CollectionSpace::Mapper::Error
    end

    class ReconstituteCachedNilValueError < TypeError
      include CollectionSpace::Mapper::Error

      def initialize
        msg = "Cannot reconstitute from NilValue"
        super(msg)
      end
    end

    class UnknownSplitterMode < TypeError
      include CollectionSpace::Mapper::Error
    end

    class UnparseableDateError < Date::Error
      include CollectionSpace::Mapper::Error

      def initialize(date_string)
        @date_string = date_string
        super
      end

      def set_column(colval)
        @column = colval
      end

      def to_h
        {
          category: :unparseable_date,
          field: column,
          value: date_string,
          message: message
        }
      end

      def message
        "Unparseable date value in #{column}: `#{date_string}`"
      end

      private

      attr_reader :date_string, :column
    end

    class UnparseableRefNameUrnError < StandardError
      include CollectionSpace::Mapper::Error

      attr_reader :urn

      def initialize(urn)
        @urn = urn
        message = "Tried to parse: #{urn}"
        super(message)
      end
    end

    class UnprocessableHandlerSignature < ArgumentError
      include CollectionSpace::Mapper::Error
    end

    class UnrecognizedGroupPatternError < StandardError
      include CollectionSpace::Mapper::Error

      attr_reader :xpath

      def initialize(xpath)
        @xpath = xpath
        super(xpath.path)
      end
    end

    # @todo What are we doing with :message_from_err ?
    class UnparseableStructuredDateError < Date::Error
      include CollectionSpace::Mapper::Error

      attr_reader :date_string, :mappable, :orig_err

      def initialize(date_string:, mappable:, orig_err: nil, desc: nil)
        @date_string = date_string
        @orig_err = orig_err
        @mappable = mappable
        @desc = desc
        super
      end

      def set_column(colval)
        @column = colval
      end

      def to_h
        {
          category: :unparseable_structured_date,
          field: column,
          value: date_string,
          message: message
        }
      end

      def message
        "Unparseable structured date in #{column}: `#{date_string}`"
      end

      private

      attr_reader :desc, :column

      def message_from_err
        return nil unless orig_err

        orig_err.message
      end
    end

    class UnprocessableDataError < StandardError
      include CollectionSpace::Mapper::Error

      attr_reader :input

      def initialize(message, input)
        super(message)
        @input = input
      end
    end
  end
end
