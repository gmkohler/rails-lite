require 'uri'
class Params
  # merges params from
  # 1. query string
  # 2. post body
  # 3. route params
  #
  # assumes route params will be
  # passed in as a hash to `Params.new` as below:
  def initialize(req, route_params = {})
    @params = {}

    if req.query_string
      @params.merge!(parse_www_encoded_form(req.query_string))
    end

    @params.merge!(parse_www_encoded_form(req.body)) if req.body
    @params.merge!(route_params)
  end

  def [](key)
    @params[key.to_s] || @params[key.to_sym]
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # returns deeply nested hash
  # argument format:
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main"}, "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    decoded = URI::decode_www_form(www_encoded_form)
    parsed_keys_ary = decoded.map! {|keys, val| [parse_key(keys), val]}
    ret_hash = Hash.new {|h, k| h[k] = {}}
    parsed_keys_ary.each do |keys, val|
      ret_hash = load_nested_keys(ret_hash, keys, val)
    end
    ret_hash
  end

  def load_nested_keys(hash, key_arr, val)
    if key_arr.size == 1
      hash[key_arr.first] = val
    else
      key = key_arr.first
      hash[key] ||= {}
      hash[key].merge(load_nested_keys(hash[key], key_arr.drop(1), val))
    end
    hash
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
