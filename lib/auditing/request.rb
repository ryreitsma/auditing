module Auditing
  class Request
    include Mordor::Resource

    attribute :url
    attribute :url_parts, :index => true
    attribute :method
    attribute :params
    attribute :user_id, :finder_method => :find_by_user, :index => true
    attribute :real_user_id, :index => true
    attribute :at, :index => true
    attribute :timestamp, :timestamp => true, :index => true

    def url=(url)
      self.url_parts = url_to_parts(url)
      @url = url
    end

    def modifications
      Modification.find_by_request(_id.to_s)
    end

    def url_parts=(parts)
      @url_parts = self.replace_params(parts)
    end

    def params=(params)
      @params = self.replace_params(params)
    end

    def self.find_by_url(url, partial = false)
      if partial
        Mordor::Collection.new(self, self.collection.find(:url => /.*#{url}.*/))
      else
        Mordor::Collection.new(self, self.collection.find(:url => url))
      end
    end

    def self.find_by_url_parts(params = {})
      parts_params = {}
      params.each do |key, value|
        parts_params["url_parts.#{key}"] = value
      end
      Mordor::Collection.new(self, self.collection.find(parts_params))
    end

    private

    def self.collection_name
      'audit_requests'
    end

    def url_to_parts(url)
      result = {}
      if url
        url.scan(/([\w|_]+)\/([\d|-]+)/).each do |key, value|
          key = key.gsub(/\W|\./, "_")
          result[key.to_sym] = value.match(/-/) ? value : value.to_i
        end
      end
      result
    end
  end
end
