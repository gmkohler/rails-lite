require 'uri'
require 'byebug'
module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}

      if req.query_string
        @params.merge!(parse_www_encoded_form(req.query_string))
      end

      @params.merge!(parse_www_encoded_form(req.body)) if req.body
      @params.merge!(route_params)
    end

    # assumes you wouldn't be storing each of params["key"] and params[:key]
    # with different values.
    def [](key)
      @params[key.to_s] || @params[key.to_sym]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    # private
    # this should return deeply nested hash
    # argument format
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
    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
