require 'output/log_file_store'

describe Output::LogFileStore do
  describe 'LogFileStore' do
    context 'given options nil' do
      let(:options_nil) { nil }
      subject { Output::LogFileStore.new(options_nil) }
      it 'gets initialized' do
        expect(subject).not_to be_nil
      end

      it 'configure returns false' do
        expect(subject.configure).to be_falsy
      end

      it 'write returns false' do
        expect(subject.write('test')).to be_falsy
      end
    end

    context 'given options with invalid directory' do
      dir_path = '/tmp/temp'
      let(:options_invalid_dir) { { 'filename' => dir_path } }
      subject { Output::LogFileStore.new(options_invalid_dir) }

      before do
        Dir.mkdir(dir_path)
      end

      after do
        Dir.rmdir(dir_path)
      end

      it 'gets initialized' do
        expect(subject).not_to be_nil
      end

      it 'configure returns false' do
        expect(subject.configure).to be_falsy
      end

      it 'write returns false' do
        expect(subject.write('test')).to be_falsy
      end
    end

    context 'given valid options' do
      dir_path = '/tmp/temp'
      let(:options_valid_filename) { { 'filename' => "#{dir_path}/test.log" } }
      subject { Output::LogFileStore.new(options_valid_filename) }
      before do
        Dir.mkdir(dir_path)
        Dir.foreach(dir_path) do |f|
          fn = File.join(dir_path, f)
          File.delete(fn) unless File.directory?(fn)
        end
      end

      after do
        File.delete(options_valid_filename['filename'])
        Dir.rmdir(dir_path)
      end

      it 'gets initialized' do
        expect(subject.configure).not_to be_nil
      end

      it 'creates a new file when not present already' do
        subject.configure
        expect(File.exist?(options_valid_filename['filename'])).to be true
      end

      it 'uses existing file when present already' do
        logfile = File.new(options_valid_filename['filename'], 'w')
        logfile.close
        subject.configure
        count = 0
        Dir.foreach(dir_path) do |f|
          fn = File.join(dir_path, f)
          count += 1 unless File.directory?(fn)
        end
        expect(count).to equal(1)
      end

      it 'can write data to a new file' do
        subject.configure
        subject.write('test')
        content = File.read(options_valid_filename['filename'])
        expect(content).to eq('test')
      end

      it 'can append data to an existing file' do
        subject.configure
        subject.write('first')
        subject.write('second')
        content = File.read(options_valid_filename['filename'])
        expect(content).to eq('firstsecond')
      end
    end
  end
end
