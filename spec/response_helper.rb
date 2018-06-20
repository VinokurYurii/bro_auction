# frozen_string_literal: true

def parse_json_string(string)
  JSON.parse(string, symbolize_names: true)
end

def get_serialize_object(obj, serializer)
  serializer ||= "#{ obj.class_name }Serializer".constantize
  serializer.new(obj).serializable_hash.as_json.deep_symbolize_keys
end
