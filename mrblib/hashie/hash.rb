module Hashie
  class Hash < ::Hash
    include Extensions::PrettyInspect
    include Extensions::StringifyKeys
  end
end
