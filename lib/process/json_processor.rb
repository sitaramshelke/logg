module Process
  class JsonProcessor
    attr_reader :event_queue

    def initialize(store_instance, options)
      @event_queue = Queue.new  # Thread safe queue
      @store_instance = store_instance
      @current_thread = nil
      @options = options
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
          event = pre_mutations(event)
          event = process_event(event)
          output = post_mutations(event)
          @store_instance.write("#{output}\n")
        end
      end
    end

    def process_event(event)
      event
    end

    def pre_mutations(event)
      run_mutations(event, @options['pre-mutations'] || [])
    end

    def post_mutations(event)
      run_mutations(event, @options['post-mutations'] || [])
    end

    def run_mutations(event, mutations)
      old = event
      current = event
      mutations.each do |m|
        code = m['value'] || ''
        y = get_lambda(code)
        current = execute_lambda(old, y)
        old = current
      end
      current
    end

    def get_lambda(code)
      eval(code)   # TODO: Safeguard this
    rescue StandardError
      proc { |a| a }
    end

    def execute_lambda(event, lmd)
      lmd.call(event)
    rescue StandardError
      event
    end
  end
end
