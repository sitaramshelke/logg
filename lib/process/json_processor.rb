module Process
  class JsonProcessor
    attr_reader :event_queue

    def initialize(store_instance, _options)
      @event_queue = Queue.new  # Thread safe queue
      @store_instance = store_instance
      @current_thread = nil
    end

    def start
      @current_thread = Thread.new { process }
      # @current_thread.join
    end

    def stop
      # nothing as of now
    end

    def process
      loop do
        until @event_queue.length.zero?
          event = @event_queue.pop
          output = process_event(event)
          @store_instance.write("#{output}\n")
        end
      end
    end

    def process_event(event)
      str = ''
      event.each do |k, v|
        str += " #{k}:#{v}"
      end
      str
    end
  end
end
