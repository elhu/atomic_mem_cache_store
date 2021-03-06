module AtomicStore
  VERSION = File.read(File.join(File.dirname(__FILE__),'..','VERSION') ).strip
  NEWLY_STORED = "STORED\r\n"

  module ClassMethods
    attr_accessor :grace_period
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.grace_period = 90
  end

  def read(key, options = nil)
    result = super(key, (options || {}).merge(options_for_parent))

    if result.present?
      timer_key = timer_key(key)
      # check whether the cache is expired
      if @data.get(timer_key, raw_arg).nil?
        # optimistic lock to avoid concurrent recalculation
        if @data.add(timer_key, '', self.class.grace_period, raw_arg) == NEWLY_STORED
          # trigger cache recalculation
          return handle_expired_read(key,result)
        end
        # already recalculated or expirated in another process/thread
      end
      # key not expired
    end
    result
  end

  def write(key, value, options = nil)
    expiry = (options && options[:expires_in]) || 0
    # extend write expiration period and reset expiration timer
    options[:expires_in] = expiry + 2 * self.class.grace_period unless expiry.zero?
    @data.set(timer_key(key), '', expiry, raw_arg)
    super(key, value, (options || {}).merge(options_for_parent))
  end

  protected

  #to be overidden for something else than synchronous cache recalculation
  def handle_expired_read(key, result)
    nil
  end

  private

  def timer_key(key)
    "tk:#{key}"
  end
end
