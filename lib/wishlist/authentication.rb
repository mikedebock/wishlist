module Wishlist
  class Authentication
    
    RESOURCE_PATH = '/auth'
    
    attr_accessor :url
    attr_accessor :key
    attr_accessor :lock_key_hash
    attr_accessor :agent
    attr_accessor :authenticated
    
    def initialize(site, key)
      @url = "#{site}#{Wishlist::API_ENDPOINT}"
      @key = key
      @authenticated = false
      initialize_mechanize
      authenticate
    end
        
    def authenticate
      if !@authenticated
        get
        post
      end
    end
    
    def get
      page = agent.get path
      body = JSON.parse(page.body)
      raise 'No auth lock to open' if body['success'].to_i != 1 || body['lock'].empty?
      prepare_hash body['lock']
    end
    
    def post
      page = agent.post path, { 'key' => @lock_key_hash }
      body = JSON.parse(page.body)
      @authenticated = true if body['success'].to_i == 1
    end
    
    def valid?
      !url.empty? || !key.empty?
    end
    
    
    private
    
    def path
      "#{@url}#{RESOURCE_PATH}"
    end
    
    def initialize_mechanize
      @agent = Mechanize.new { |agent| 
        agent.user_agent_alias = 'Mechanize'
        if defined?(Rails) and not Rails.env.production?
          agent.log = Logger.new('log/%s-mechanize.log' % Rails.env)
        end
      }
    end
    
    def prepare_hash(lock)
      @lock_key_hash = Digest::MD5.hexdigest(lock + @key)
    end
    
  end
end
