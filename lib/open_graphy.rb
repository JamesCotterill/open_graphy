require "open_graphy/version"
require "nokogiri"
require "open-uri"
require "singleton"
require "open_graphy/configuration"
require "open_graphy/fetcher"
require "open_graphy/data"

module OpenGraphy
  def self.configuration
    Configuration.instance
  end

  def self.configure
    yield(configuration)
  end

  def self.fetch(uri)
    Fetcher.fetch(uri)
  end
end
