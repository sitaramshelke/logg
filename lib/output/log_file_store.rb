module Output
  class LogFileStore
    def initialize(options)
      @options = options
    end

    def configure
      filename = @options['filename']
      return false if filename.nil?
      return false if File.directory? filename
      return false if File.exist?(filename) && !File.writable?(filename)

      unless File.exist?(filename)
        f = File.new(@options['filename'], 'w')
        f.close
      end

      true
    end

    def write(data)
      File.open(@options['filename'], 'a') do |f|
        f.write(data)
      end
    end

    def start
      # nothing as of now
    end

    def stop
      # nothing as of now
    end
  end
end