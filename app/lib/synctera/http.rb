module Synctera
  module Http
    def get(path, options = {})
      conn.get(path, options).try(:body)
    end

    def post(path, body, options = {})
      conn.post(path, body, options).try(:body)
    end

    def patch(path, body, options = {})
      conn.patch(path, body, options).try(:body)
    end

    def conn
      @conn ||= Faraday.new(url: @base_url) do |f|
        f.request :url_encoded
        f.request :authorization, :bearer, @api_key
        f.use MiddlewareErrors
        f.response :raise_error
        f.response :json
      end
    end
  end
end
