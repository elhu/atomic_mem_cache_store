require 'active_support'
require 'dalli'
require 'active_support/cache/dalli_store23'
require 'dalli/memcache-client'
require 'atomic_store'

class AtomicDalliStore < ActiveSupport::Cache::DalliStore
  include AtomicStore

  def raw_arg
    @raw_arg ||= { :raw => true }
  end

  def options_for_parent
    @options_for_parent ||= { :raw => false }
  end
end
