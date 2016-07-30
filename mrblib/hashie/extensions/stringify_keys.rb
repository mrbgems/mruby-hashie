module Hashie
  module Extensions
    module StringifyKeys
      def stringify_keys!
        StringifyKeys.stringify_keys!(self)
        self
      end

      def stringify_keys
        StringifyKeys.stringify_keys(self)
      end

      module ClassMethods
        def stringify_keys_recursively!(object)
          case object
          when self.class
            stringify_keys!(object)
          when ::Array
            object.each do |i|
              stringify_keys_recursively!(i)
            end
          when ::Hash
            stringify_keys!(object)
          end
        end

        def stringify_keys!(hash)
          hash.extend(Hashie::Extensions::StringifyKeys) unless hash.respond_to?(:stringify_keys!)
          hash.keys.each do |k|
            stringify_keys_recursively!(hash[k])
            hash[k.to_s] = hash.delete(k)
          end
          hash
        end

        def stringify_keys(hash)
          copy = hash.dup
          copy.extend(Hashie::Extensions::StringifyKeys) unless copy.respond_to?(:stringify_keys!)
          copy.tap do |new_hash|
            stringify_keys!(new_hash)
          end
        end
      end

      class << self
        include ClassMethods
      end
    end
  end
end
