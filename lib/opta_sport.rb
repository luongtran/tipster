# Build on: 14/March/2014
# Author: LuanHt

require 'active_support/configurable'

module OptaSport
  def self.configure(&block)
    yield @config ||= OptaSport::Configuration.new
  end

  def self.config
    @config
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :username
    config_accessor :auth_key
  end
end