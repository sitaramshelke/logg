require 'output/log_file_store'

describe Output::LogFileStore do
  describe 'LogFileStore' do
    context 'given options nil' do
      it 'gets initialized'
      it 'validate returns false'
      it 'configure returns false'
      it 'write returns false'
    end

    context 'given options with invalid directory' do
      it 'gets initialized'
      it 'validate returns false'
      it 'configure returns false'
      it 'write returns false'
    end

    context 'given valid options' do
      it 'gets initialized'
      it 'validate returns true'
      it 'creates a new file when not present already'
      it 'uses existing file when present already'
      it 'can write data to a new file'
      it 'can append data to an existing file'
    end
  end
end
