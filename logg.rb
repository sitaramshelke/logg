require 'net/http/server'
require 'pry'
require 'pp'
require 'json'

EVENT_QUEUE = []
$server = nil

def initialize_server
  $server = Net::HTTP::Server.run(port: 8080, background: true) do |request, stream|
    len = request[:headers]['Content-Length'].to_i
    body = ''
    stream.read(len, body)
    data = JSON.parse(body)
    pp data
    EVENT_QUEUE << data

    [200, { 'Content-Type': 'text/json' }, []]
  end
end

def process_event(event)
  str = ''
  event.each do |k, v|
    str += " #{k}:#{v}"
  end
  str
end

def append(str)
  open('test.log', 'a') do |f|
    f.puts(str)
  end
end

def trap_signals
  trap('TERM') do
    $server.stop
    pp 'Exiting..'
    exit(0)
  end
end

def main_loop

  loop do
    EVENT_QUEUE.each do |event|
      output = process_event(event)
      append(output)
      EVENT_QUEUE.shift
    end
  end
end

trap_signals
initialize_server
main_loop


