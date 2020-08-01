require 'net/http/server'
require 'json'

module Input
  CONTENT_LENGTH = 'Content-Length'.freeze
  CONTENT_TYPE = 'Content-Type'.freeze
  REQUIERD_CONTENT_TYPE = 'application/json'.freeze

  class HTTPServer
    def initialize(host, port, event_queue)
      @event_queue = event_queue
      @server = nil
      @host = host
      @port = port
    end

    def register
      puts 'Registration successful'
    end

    def start
      @server = Net::HTTP::Server.run(server_options) do |request, stream|
        valid, len = validate_request(request)
        return bad_request unless valid

        data = event_data(stream, len)
        return bad_request if data.nil?

        @event_queue << data
        success
      end
    end

    def stop
      @server.stop
    end

    private

    def success
      [200, { 'Content-Type': 'text/json' }, []]
    end

    def bad_request
      [401, { 'Content-Type': 'text/json' }, []]
    end

    def server_options
      { host: @host, port: @port, background: true }
    end

    def validate_request(request)
      type = request[:headers][CONTENT_TYPE]
      len = request[:headers][CONTENT_LENGTH].to_i
      return [true, len] if type == REQUIERD_CONTENT_TYPE && len.positive?

      [false, 0]
    end

    def event_data(stream, len)
      body = ''
      begin
        stream.read(len, body)
        data = JSON.parse(body)
      rescue StandardError
        return nil
      end
      data
    end


  end

end