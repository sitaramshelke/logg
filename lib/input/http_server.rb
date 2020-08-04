require 'net/http/server'
require 'json'

# Module Input will act as a namespace for all the inputs
module Input
  CONTENT_LENGTH = 'Content-Length'.freeze
  CONTENT_TYPE = 'Content-Type'.freeze
  REQUIERD_CONTENT_TYPE = 'application/json'.freeze

  # HTTPServer is concrete implmentation of BaseInput. It will work with
  # events over HTTP protocol and runs and embedded HTTP server. Server
  # should be able to consume events in different media formats JSON, Text.
  class HTTPServer
    def initialize(event_queue, options)
      @event_queue = event_queue
      @server = nil
      @host = options['host']
      @port = options['port']
    end

    def register
      puts 'Registration successful'
      true
    end

    def running?
      @server != nil
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