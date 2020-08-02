require 'yaml'

module Engine
  Dir[File.join(__dir__, '..', 'input', '*.rb')].each { |file| require file }
  Dir[File.join(__dir__, '..', 'process', '*.rb')].each { |file| require file }
  Dir[File.join(__dir__, '..', 'output', '*.rb')].each { |file| require file }

  module ConfigParser
    def parse
      @config = YAML.load_file(@filepath)
      validate
    end

    private

    def validate
      return false unless valid_inputs?
      return false unless valid_processes?
      return false unless valid_outputs?

      true
    end

    def valid_inputs?
      return false if @config['Inputs'].nil?

      true
    end

    def valid_processes?
      return false if @config['Processes'].nil?

      true
    end

    def valid_outputs?
      return false if @config['Outputs'].nil?

      true
    end
  end

  module ConfigBuilder
    def build
      build_output
      build_processes
      build_input
    end

    private

    def build_output
      @config['Outputs'].each do |name, options|
        klass = store_from_type(options['type'])
        @outputs[name] = klass.new(options)
      end
    end

    def build_processes
      @config['Processes'].each do |name, options|
        klass = processor_from_type(options['type'])
        store = @outputs[options['output']]
        @processes[name] = klass.new(store, options)
      end
    end

    def build_input
      @config['Inputs'].each do |name, options|
        klass = input_from_type(options['type'])
        p = @processes[options['process']]
        @inputs[name] = klass.new(p.event_queue, options)
      end
    end

    def store_from_type(type)
      klass = case type
              when 'log-file'
                Output::LogFileStore
              end
      klass
    end

    def processor_from_type(type)
      klass = case type
              when 'json'
                Process::JsonProcessor
              end
      klass
    end

    def input_from_type(type)
      klass = case type
              when 'http-json'
                Input::HTTPServer
              end
      klass
    end
  end

  class Core
    include Engine::ConfigParser
    include Engine::ConfigBuilder

    attr_reader :config

    def initialize(filepath)
      @filepath = filepath
      @config = nil
      @inputs = {}
      @processes = {}
      @outputs = {}
    end

    def setup
      return false unless parse && build

      true
    end

    def start
      @inputs.each { |_n, inst| inst.start }
      @processes.each { |_n, inst| inst.start }
      @outputs.each { |_n, inst| inst.start }
    end

    def stop
      @inputs.each { |_n, inst| inst.stop }
      @processes.each { |_n, inst| inst.stop }
      @outputs.each { |_n, inst| inst.stop }
    end
  end
end
