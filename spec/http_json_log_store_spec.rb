require 'engine/engine'
require 'tempfile'
require 'yaml'
require 'net/http'

describe 'HTTP server with JSON processor and LogFileStore' do
  it 'single event is injested successfully and returns 200' do
    perform_with_engine do
      status = post_http_request('127.0.0.1', '8080', headers, sample_json_log)
      expect(status).to equal(200)
    end
  end

  it 'single event is ingested and written to log file' do
    perform_with_engine do |outfile|
      post_http_request('127.0.0.1', '8080', headers, sample_json_log)
      lines = outfile.read.count("\n")
      expect(lines).to equal(1)
    end
  end

  it 'multiple events are ingested successfully' do
    perform_with_engine do |outfile|
      threads = []
      3.times do |n|
        threads << Thread.new { post_http_request('127.0.0.1', '8080', headers, sample_json_log(n)) }
      end
      threads.each(&:join)
      sleep(3) # A hack to wait for the changes to be written in file
      lines = outfile.read
      puts lines
      suffixes = [0, 1, 2]
      lines.split("\n").each { |l| suffixes -= [l[-1].to_i] }

      expect(lines.count("\n")).to equal(3)
      expect(suffixes.length).to equal(0)
    end
  end
end

def perform_with_engine
  outfile = Tempfile.new(['app', '.log'])
  conf_file = Tempfile.new(['http_json_config', '.yml'])
  conf_file.write(conf_str(outfile.path))
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

def conf_str(logfile_path)
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
                event[:ip] = '*.*.*.*'
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
      port: 8080

  YML
end

def headers
  { Input::CONTENT_TYPE => Input::REQUIERD_CONTENT_TYPE }
end

def sample_json_log(num = 1)
  {
    'timestamp': Time.now.to_s,
    'message': "INFO: This is a sample log #{num}"
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
