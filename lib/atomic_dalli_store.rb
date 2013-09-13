require 'dalli'
require 'dalli/memcache-client'
require 'active_support/cache/dalli_store23'
require 'atomic_store'

class AtomicDalliStore < ActiveSupport::Cache::DalliStore
  include AtomicStore

  def raw_arg
    @raw_arg ||= { :raw => true }
  end
end
