module Hashie
  class Mash < Hash
    ALLOWED_SUFFIXES = %w(? ! = _)

    def initialize(source_hash = nil, default = nil, &blk)
      deep_update(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    class << self; alias_method :[], :new; end

    alias_method :regular_reader, :[]
    alias_method :regular_writer, :[]=

    def custom_reader(key)
      default_proc.call(self, key) if default_proc && !key?(key)
      value = regular_reader(convert_key(key))
      yield value if block_given?
      value
    end

    def custom_writer(key, value, convert = true) #:nodoc:
      regular_writer(convert_key(key), convert ? convert_value(value) : value)
    end

    alias_method :[], :custom_reader
    alias_method :[]=, :custom_writer

    def initializing_reader(key)
      ck = convert_key(key)
      regular_writer(ck, self.class.new) unless key?(ck)
      regular_reader(ck)
    end

    def underbang_reader(key)
      ck = convert_key(key)
      if key?(ck)
        regular_reader(ck)
      else
        self.class.new
      end
    end

    def fetch(key, *args)
      super(convert_key(key), *args)
    end

    def delete(key)
      super(convert_key(key))
    end

    def values_at(*keys)
      super(*keys.map { |key| convert_key(key) })
    end

    alias_method :regular_dup, :dup
    # Duplicates the current mash as a new mash.
    def dup
      self.class.new(self, default)
    end

    def key?(key)
      super(convert_key(key))
    end
    alias_method :has_key?, :key?
    alias_method :include?, :key?
    alias_method :member?, :key?

    def deep_merge(other_hash, &blk)
      dup.deep_update(other_hash, &blk)
    end
    alias_method :merge, :deep_merge

    def deep_update(other_hash, &blk)
      other_hash.each_pair do |k, v|
        key = convert_key(k)
        if regular_reader(key).is_a?(Mash) && v.is_a?(::Hash)
          custom_reader(key).deep_update(v, &blk)
        else
          value = convert_value(v, true)
          value = convert_value(blk.call(key, self[k], value), true) if blk && self.key?(k)
          custom_writer(key, value, false)
        end
      end
      self
    end
    alias_method :deep_merge!, :deep_update
    alias_method :update, :deep_update
    alias_method :merge!, :update

    def assign_property(name, value)
      self[name] = value
    end

    def replace(other_hash)
      (keys - other_hash.keys).each { |key| delete(key) }
      other_hash.each { |key, value| self[key] = value }
      self
    end

    def respond_to_missing?(method_name, *args)
      return true if key?(method_name)
      suffix = method_suffix(method_name)
      if suffix
        true
      else
        super
      end
    end

    def method_missing(method_name, *args, &blk)
      return self.[](method_name, &blk) if key?(method_name)
      name, suffix = method_name_and_suffix(method_name)
      case suffix
      when '='.freeze
        assign_property(name, args.first)
      when '?'.freeze
        !!self[name]
      when '!'.freeze
        initializing_reader(name)
      when '_'.freeze
        underbang_reader(name)
      else
        self[method_name]
      end
    end

    def reverse_merge(other_hash)
      self.class.new(other_hash).merge(self)
    end

    def reverse_merge!(other_hash)
      replace(self.class.new(other_hash).deep_update(self))
    end

    protected

    def method_name_and_suffix(method_name)
      method_name = method_name.to_s
      if method_name.end_with?(*ALLOWED_SUFFIXES)
        [method_name[0..-2], method_name[-1]]
      else
        [method_name[0..-1], nil]
      end
    end

    def method_suffix(method_name)
      method_name = method_name.to_s
      method_name[-1] if method_name.end_with?(*ALLOWED_SUFFIXES)
    end

    def convert_key(key)
      key.to_s
    end

    def convert_value(val, duping = false)
      case val
      when self.class
        val.dup
      when Hash
        duping ? val.dup : val
      when ::Hash
        val = val.dup if duping
        self.class.new(val)
      when Array
        val.map { |e| convert_value(e) }
      when ::Array
        Array.new(val.map { |e| convert_value(e) })
      else
        val
      end
    end
  end
end
