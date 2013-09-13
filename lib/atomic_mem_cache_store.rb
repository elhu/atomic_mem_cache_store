require 'active_support'
require 'atomic_store'

class AtomicMemCacheStore < ActiveSupport::Cache::CompressedMemCacheStore
  include AtomicStore

  def raw_arg
    true
  end
end
