class Settings
  include Singleton
  
  class << self
    def respond_to?(method)
      super or self.instance.respond_to?(method)
    end
    
  protected
    
    def method_missing(method, *args, &block)
      return super unless self.instance.respond_to?(method)
      self.instance.send(method, *args, &block)
    end
    
  end
  
  def initialize
    @settings = YAML.load(File.read(File.join(File.dirname(__FILE__), *%W[.. settings #{RAILS_ENV}.yml])))
  end
  
  def respond_to?(method)
    super or @settings.key?(method.to_s)
  end
  
protected
  
  def method_missing(method, *args, &block)
    return super unless @settings.key?(method.to_s)
    @settings[ method.to_s ]
  end
  
end

Settings.instance