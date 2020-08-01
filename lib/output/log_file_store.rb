module Output
  class LogFileStore
    def initialize(options)
      @options = options
    end

    def configure
      file_path = @options[:file_path]
      return false if file_path.nil?
      return false if File.directory? file_path
      return false if File.exist?(file_path) && !File.writable?(file_path)

      unless File.exist?(file_path)
        f = File.new(@options[:file_path], 'w')
        f.close
      end

      true
    end

    def write(data)
      File.open(@options[:file_path], 'a') do |f|
        f.write(data)
      end
    end
  end
end