require 'input/http_server'
require 'process/json_processor'
require 'output/log_file_store'

class Logg
  def initialize
    @stopped = false
  end


  def start
    http_event_queue = []
    http_server = Input::HTTPServer.new('0.0.0.0', 8080, http_event_queue)
    log_store = Output::LogFileStore.new(file_path: 'test.log')
    json_processor = Process::JsonProcessor.new(http_event_queue, log_store)

    begin
      unless log_store.configure
        puts 'Could not access log file!!'
        exit(0)
      end

      http_server.start
      json_processor.start
      puts "started.."
      sleep 1 until @stopped
    rescue SystemExit, Interrupt
      puts 'Got exception..'
      @stopped = true
    end
  end

  private

  def trap_signals
    trap('INT') do
      @stopped = true
      puts 'Exiting..'
      exit(0)
    end
  end

end