# frozen_string_literal: true

module CollectionSpace
  module Mapper
    module DateDetails
      class Handler < CollectionSpace::Mapper::HandlerFullRecord
        attr_reader :grouped_handler, :grouped_fields, :target_path

        def check_fields(data)
          initial = super(data)
          @grouped_fields = []
          return initial if initial[:unknown_fields].empty?

          known = known_grouped(initial[:unknown_fields], data)
          return initial if known.empty?

          @grouped_fields = known
          known.each do |field|
            initial[:known_fields] << field
            initial[:unknown_fields].delete(field)
          end
          if initial[:unknown_fields].empty?
            @grouped_handler = CollectionSpace::Mapper::HandlerFullRecord.new(
              record_mapper: record_mapper, client: client, cache: termcache,
              csid_cache: csidcache
            )
          end
          initial
        end

        private

        attr_reader :record_mapper

        def pre_initialize(context)
          config.batch_mode = "date details"
          @record_mapper = context.local_variable_get(:record_mapper)
          @grouped_handler = nil
          @grouped_fields = nil
          @target_path = nil
        end

        def get_prepper_class
          CollectionSpace::Mapper::DateDetails::DataPrepper
        end

        def get_date_handler
          nil
        end

        def known_fields
          base = [
            record.identifier_field,
            "date_field_group",
            CollectionSpace::Mapper.structured_date_detailed_fields
          ].flatten
            .map(&:downcase)
          return base unless record.service_type == "authority"

          base << "termdisplayname"
          base
        end

        def known_grouped(fields, data)
          target = data["date_field_group"]
          @target_path = date_group_path(target)
          in_group = grouped_fields_for
          return [] if in_group.empty?

          fields.select { |field| in_group.include?(field) }
        end

        def grouped_fields_for
          record.mappings
            .select { |mapping| mapping.fullpath == target_path }
            .map(&:datacolumn)
        end

        def date_group_path(target)
          record.mappings
            .select { |m| m.fieldname == target }
            .first
            .fullpath
        end
      end
    end
  end
end
