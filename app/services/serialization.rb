# frozen_string_literal: true

#  To generalize serialization method for single record, Array or ActiveRecord::Relation
module Serialization
  extend ActiveSupport::Concern

  # ---------- INCLUSIVE PROPERTIES -----------
  included do
    # --------- PACKAGE INCLUSION -------------
    include Pagy::Backend
  end

  # ------------- PUBLIC METHODS --------------

  def serialize(data = nil, **options)
    options[:root] ||= :data
    serializer = options.delete(:serializer) || options.delete(:each_serializer)

    case data
    when Array, ActiveRecord::Relation, ActiveRecord::Associations::CollectionProxy
      return handle_array_serialization(data, options) if options.delete(:multiple_models)

      serialize_collection(data, serializer, data.sample.class, options)
    else
      serialize_single(data, serializer, data.class, options)
    end
  end

  # ------------- PRIVATE METHODS --------------
  private

  def serialize_single(record, serializer, record_model, serializer_options = {})
    serializer ||= begin
      Module.const_get("::#{record_model.name}Serializer")
    rescue StandardError
      nil
    end

    return { serializer_options[:root] => nil } unless record.present? && serializer.present?

    set_inclusions(serializer, serializer_options)
    _serialize(record, serializer_options.merge(serializer:))
  end

  def serialize_collection(collection, serializer, collection_model, serializer_options = {})
    serializer ||= begin
      Module.const_get("::#{collection_model.name}Serializer")
    rescue StandardError
      nil
    end

    return { serializer_options[:root] => [] } unless serializer

    set_inclusions(serializer, serializer_options)
    collection = paginate!(collection, collection_model, serializer_options) if serializer_options.delete(:paginate)

    _serialize(collection, serializer_options.merge(each_serializer: serializer))
  end

  def handle_array_serialization(array, multi_serializer_options = {})
    root_key = multi_serializer_options.delete(:root) || :data
    final_result = { root_key => {}, included: [] }

    current_user = multi_serializer_options[:current_user]

    array.each do |collection|
      collection[:current_user] = current_user if current_user
      handle_nested_collection(collection, final_result, root_key)
    end
    final_result
  end

  def handle_nested_collection(collection, final_result, result_root_key)
    data, serializer, each_serializer, serialization_options = collection.values_at(
      :data, :serializer, :each_serializer
    ).tap { |h| h << collection.except(:data, :serializer, :each_serializer) }

    root = serialization_options.delete(:root) || :data

    serialized_col = serialize(data, **serialization_options.merge(serializer: serializer || each_serializer), root:)
    final_result[:included] |= serialized_col[:included] || []
    final_result[result_root_key][root] = serialized_col[root] || serialized_col[:data]
  end

  def paginate!(collection, collection_model, pagination_options = {})
    pagy, collection = paginated_data(collection, pagination_options.delete(:pagination_params) || {})
    api_response.pagination[pagination_options[:root] || collection_model&.table_name&.split('.')&.last] =
      pagy_metadata(pagy)
    collection
  end

  def paginated_data(collection, pagination_params = {})
    page_number = pagination_params[:page].to_i
    items_count = pagination_params[:items].to_i

    options = {}
    options[:page] = page_number if page_number.positive?
    options[:items] = items_count if items_count.positive?
    pagy_array(collection, **options)
  end

  def set_inclusions(serializer, options = {})
    options[:include] ||= []
    return if options.delete(:skip_inclusions)

    only_inclusion_list = options.delete(:only_include)
    options[:include] = only_inclusion_list and return if only_inclusion_list

    inluded_tables_list = serializer.try('inclusions_list') || []
    options[:include] = options[:include] | inluded_tables_list
  end

  def _serialize(data, serializer_options = {})
    ::ActiveModelSerializers::SerializableResource.new(data, **serializer_options)&.serializable_hash
  end
end
