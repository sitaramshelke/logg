require 'engine/engine'
require 'tempfile'
require 'yaml'
require 'net/http'
require 'byebug'

describe 'HTTP server with JSON processor and LogFileStore' do
  it 'single event is injested successfully and returns 200' do
    port = rand_port
    perform_with_engine(port) do
      status = post_http_request('127.0.0.1', port, headers, sample_json_log)
      expect(status).to equal(200)
    end
  end

  it 'single event is ingested and written to log file' do
    port = rand_port
    perform_with_engine(port) do |outfile|
      post_http_request('127.0.0.1', port, headers, sample_json_log)
      lines = outfile.read.count("\n")
      expect(lines).to eq(1)
    end
  end

  it 'multiple events are ingested successfully' do
    port = rand_port
    perform_with_engine(port) do |outfile|
      threads = []
      outputs = []
      3.times do |n|
        event = sample_json_log(n)
        outputs << event.to_s
        threads << Thread.new { post_http_request('127.0.0.1', port, headers, event)}
      end
      threads.each(&:join)
      sleep(3) # A hack to wait for the changes to be written in file
      lines = outfile.read
      input = lines.split("\n")
      diff = input - outputs

      expect(input.length).to eq(outputs.length)
      expect(diff.length).to eq(0)
    end
  end
end

def perform_with_engine(port)
  outfile = Tempfile.new(["app-#{rand(1..9)}", '.log'])
  conf_file = Tempfile.new(['http_json_config', '.yml'])
  conf_file.write(conf_str(outfile.path, port))
  conf_file.close

  engine = Engine::Core.new(conf_file.path)
  engine.setup
  engine.start

  yield(outfile)

  conf_file.unlink
  outfile.close
  outfile.unlink
  engine.stop
end

def conf_str(logfile_path, port)
  <<-YML
  Outputs:
    app-1-logs:
      type: log-file
      filename: #{logfile_path}
      flush_interval: 5
  Processes:
      app-json-logs:
        type: json
        output: app-1-logs
        pre-mutations:
          - name: mask-ip
            value: |+
              ->(event) {
                event['ip'] = '*.*.*.*'
                return event
              }
        post-mutations:
          - name: convert-to-string
            value: |+
              ->(event) {
                return event.to_str
              }
  Inputs:
    app1_logs:
      type: http-json
      process: app-json-logs
      host: '0.0.0.0'
      port: #{port}

  YML
end

def rand_port
  rand(8080..8090)
end

def headers
  { Input::CONTENT_TYPE => Input::REQUIERD_CONTENT_TYPE }
end

def sample_json_log(num = 1)
  {
    'timestamp' => Time.now.to_s,
    'ip' => '1.1.1.1',
    'message' =>  "INFO: This is a sample log #{num}"
  }
end

def post_http_request(host, port, headers, body)
  uri = URI("http://#{host}:#{port}/")
  req = Net::HTTP::Post.new(uri)
  headers.each { |k,v| req[k] = v }
  req.body = JSON.dump(body)

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end

  case res
  when Net::HTTPSuccess
    200
  when Net::HTTPBadRequest
    401
  end
end
