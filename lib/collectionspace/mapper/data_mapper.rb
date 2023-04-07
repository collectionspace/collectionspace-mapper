# frozen_string_literal: true

module CollectionSpace
  module Mapper
    class DataMapper
      attr_reader :handler, :xphash
      attr_accessor :doc, :response

      # @todo appconfig remove handler arg
      def initialize(
        response,
        handler = CollectionSpace::Mapper.data_handler,
        xphash
      )
        @response = response
        @handler = handler
        @xphash = xphash

        @data = @response.combined_data
        @doc = CollectionSpace::Mapper.recordmapper.xml_template.blankdoc
        @cache = CollectionSpace::Mapper.termcache

        @xphash.each { |xpath, hash| map(xpath, hash) }
        add_short_id if CollectionSpace::Mapper.record.service_type == "authority"
        set_response_identifier
        clean_doc
        defuse_bomb
        add_namespaces
        @response.doc = @doc
      end

      private

      def set_response_identifier
        if CollectionSpace::Mapper.record.service_type == "relation"
          set_relation_id
        else
          id_field = CollectionSpace::Mapper.record.identifier_field
          mapping = CollectionSpace::Mapper.recordmapper.mappings.find { |mapper|
            mapper.fieldname == id_field
          }
          thexpath = "//#{mapping.namespace}/#{mapping.fieldname}"
          value = @doc.xpath(thexpath).first
          value = value.text
          @response.identifier = value
        end
      end

      def set_relation_id
        case CollectionSpace::Mapper.record.object_name
        when "Object Hierarchy Relation"
          narrow = @response.orig_data["narrower_object_number"]
          broad = @response.orig_data["broader_object_number"]
          @response.identifier = "#{broad} > #{narrow}"
        end
      end

      def add_short_id
        term = @response.transformed_data["termdisplayname"][0]
        ns = CollectionSpace::Mapper.record.common_namespace
        targetnode = @doc.xpath("/document/#{ns}").first
        child = Nokogiri::XML::Node.new("shortIdentifier", @doc)
        child.content =
          CollectionSpace::Mapper::Identifiers::AuthorityShortIdentifier.new(
            term: term
          ).value
        targetnode.add_child(child)
      end

      def map(xpath, xphash)
        thisdata = @data[xpath]
        targetnode = @doc.xpath("//#{xpath}")[0]
        xphash[:mappings] = xphash[:mappings].uniq { |mapping|
          mapping.fieldname
        }
        if xphash[:is_group] == false
          simple_map(xphash, targetnode, thisdata)
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == false
          map_group(xpath, targetnode, thisdata)
        elsif xphash[:is_group] == true && xphash[:is_subgroup] == true
          map_subgroup(xphash, thisdata)
        end
      end

      def clean_doc
        @doc.traverse do |node|
          node.remove if node.text == "%NULLVALUE%"
          node.remove unless node.text.match?(/\S/m)
        end
      end

      def defuse_bomb
        @doc.traverse do |node|
          node.content = "" if node.text == CollectionSpace::Mapper.bomb
        end
      end

      def add_namespaces
        @doc.xpath("/*/*").each do |section|
          fetchuri = CollectionSpace::Mapper.record.ns_uri[section.name]
          uri = fetchuri.nil? ? "http://no.uri.found" : fetchuri
          section.add_namespace_definition(
            "ns2",
            uri
          )
          section.add_namespace_definition(
            "xsi",
            "http://www.w3.org/2001/XMLSchema-instance"
          )
          section.name = "ns2:#{section.name}"
        end
      end

      def map_structured_date(groupname, hash)
        target = groupname
        hash.each do |fieldname, value|
          child = Nokogiri::XML::Node.new(fieldname, @doc)
          child.content = value
          target.add_child(child)
        end
      end

      def simple_map(xphash, parent, thisdata)
        xphash[:mappings].each do |field_mapping|
          field_name = field_mapping.fieldname
          data = thisdata.fetch(field_name, nil)
          populate_simple_field_data(field_name, data, parent) if data
        end
      end

      def populate_simple_field_data(field_name, data, parent)
        data.each do |val|
          child = Nokogiri::XML::Node.new(field_name, @doc)
          if val.is_a?(Hash)
            map_structured_date(child, val)
          else
            child.content = val
          end
          parent.add_child(child)
        end
      end

      def populate_group_field_data(index, data, parent)
        data.each do |field, values|
          next unless values[index]

          child = Nokogiri::XML::Node.new(field, @doc)
          if values[index].is_a?(Hash)
            map_structured_date(child, values[index])
          else
            values[index]
            child.content = values[index]
          end
          parent.add_child(child)
        end
      end

      def populate_subgroup_field_data(field, data, target)
        data.each_with_index do |val, subgroup_index|
          parent = target[subgroup_index]
          child = Nokogiri::XML::Node.new(field, @doc)
          if val.is_a?(Hash)
            map_structured_date(child, val)
          else
            child.content = val
            parent&.add_child(child)
          end
        end
      end

      def subgrouplist_target(parent_path, group_index, subgroup_path, subgroup)
        grp_target = @doc.xpath("//#{parent_path}")[group_index]
        target_xpath = "#{subgroup_path.join("/")}/#{subgroup}"
        grp_target.xpath(target_xpath)
      end

      def map_subgroups_to_group(group, target)
        group[:data].each do |field, data|
          populate_subgroup_field_data(field, data, target)
        end
      end

      def map_group(xpath, targetnode, thisdata)
        pnode = targetnode.parent
        groupname = targetnode.name.dup
        targetnode.remove

        max_ct = thisdata.values.map { |v| v.size }.max
        max_ct.times do
          group = Nokogiri::XML::Node.new(groupname, @doc)
          pnode.add_child(group)
        end

        max_ct.times do |i|
          path = "//#{xpath}"
          populate_group_field_data(i, thisdata, @doc.xpath(path)[i])
        end
      end

      def even_subgroup_field_values?(data)
        data.values.map(&:flatten).map(&:length).uniq.length == 1
      end

      def add_uneven_subgroup_warning(parent_path:, intervening_path:,
                                      subgroup:)
        sgpath = "#{parent_path}/#{intervening_path.join("/")}/#{subgroup}"
        response.warnings << {
          category: :uneven_subgroup_field_values,
          field: nil,
          type: nil,
          subtype: nil,
          value: nil,
          message: "Fields in subgroup #{sgpath} have different numbers of "\
            "values"
        }
      end

      def add_too_many_subgroups_warning(parent_path:, intervening_path:,
                                         subgroup:)
        sgpath = "#{intervening_path.join("/")}/#{subgroup}"
        response.warnings << {
          category: :subgroup_contains_data_for_nonexistent_groups,
          field: nil,
          type: nil,
          subtype: nil,
          value: nil,
          message: "Data for subgroup #{sgpath} is trying to map to more "\
            "instances of parent group #{parent_path} than exist. Overflow "\
            "subgroup values will be skipped. The usual cause of this is that "\
            "you separated subgroup values that belong inside the same parent "\
            "group with the repeating field delimiter "\
            "(#{CollectionSpace::Mapper.batch.delimiter}) instead of the "\
            "subgroup delimiter "\
            "(#{CollectionSpace::Mapper.batch.subgroup_delimiter})"
        }
      end

      def group_accommodates_subgroup?(groupdata, subgroupdata)
        sg_max_length = subgroupdata.values.map(&:length).max
        sg_max_length <= groupdata.length
      end

      # EXAMPLE: creates empty titleTranslationSubGroupList as a child of
      #   titleGroup
      def create_intermediate_subgroup_hierarchy(grp, subgroup_path)
        target = grp[:parent]
        unless subgroup_path.empty?
          subgroup_path.each do |segment|
            child = Nokogiri::XML::Node.new(segment, @doc)
            target.add_child(child)
            target = child
          end
        end
      end

      # returns the count of field values for the subgroup field with the mosty
      #   values
      # we need to know this in order to create enough empty subgroup elements
      #   to hold the data
      def maximum_subgroup_values(data)
        data.map { |_field, values| subgroup_value_count(values) }.flatten.max
      end

      def subgroup_value_count(values)
        values.map { |subgroup_values| subgroup_values.length }.max
      end

      def assign_subgroup_values_to_group_hash_data(groups, field, subgroups)
        subgroups.each_with_index do |subgroup_values, group_index|
          next if groups[group_index].nil?

          groups[group_index][:data][field] = subgroup_values
        end
      end

      def map_subgroup(xphash, thisdata)
        parent_path = xphash[:parent]
        parent_set = @doc.xpath("//#{parent_path}")
        subgroup_path = xphash[:mappings][0].fullpath.gsub(
          "#{xphash[:parent]}/", ""
        ).split("/")
        subgroup = subgroup_path.pop

        # create a hash of subgroup data split up and structured for mapping
        groups = {}
        # populated it with parent group for each subgroup, keyed by group index
        parent_set.each_with_index do |p, i|
          groups[i] = {parent: p, data: {}}
        end

        unless even_subgroup_field_values?(thisdata)
          add_uneven_subgroup_warning(parent_path: parent_path,
                                      intervening_path: subgroup_path,
                                      subgroup: subgroup)
        end
        unless group_accommodates_subgroup?(groups, thisdata)
          add_too_many_subgroups_warning(parent_path: parent_path,
                                         intervening_path: subgroup_path,
                                         subgroup: subgroup)
        end

        thisdata.each { |field, subgroups|
          assign_subgroup_values_to_group_hash_data(groups, field, subgroups)
        }

        groups.values.each { |grp|
          create_intermediate_subgroup_hierarchy(grp, subgroup_path)
        }

        max_ct = maximum_subgroup_values(thisdata)

        groups.each do |i, _data|
          max_ct.times do
            target = @doc.xpath("//#{parent_path}/#{subgroup_path.join("/")}")
            target[i].add_child(Nokogiri::XML::Node.new(subgroup, @doc))
          end
        end

        groups.each do |group_index, group|
          target = subgrouplist_target(parent_path, group_index, subgroup_path,
                                       subgroup)
          map_subgroups_to_group(group, target)
        end
      end
    end
  end
end
