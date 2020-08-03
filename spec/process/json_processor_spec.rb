require 'process/json_processor'

describe Process::JsonProcessor do
  describe 'JsonProcessor' do
    context 'given invalid store instance' do
      it 'gets initialized'
      it 'initializes empty queue'
      it 'returns false on validate'
    end

    context 'provided valid store instance' do
      it 'gets initialized'
      it 'initializes empty queue'
      it 'returns true on validate'
      it 'initializes current thread instance on start'
      it 'processes and event from the queue'
      it 'processes events and writes in the same order as input'
      it 'processes an event and returns a processed output'
      it 'stops the current thread after stop'
    end
  end
end
