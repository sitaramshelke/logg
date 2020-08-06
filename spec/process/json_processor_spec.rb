require 'process/json_processor'

describe Process::JsonProcessor do
  describe 'JsonProcessor' do
    context 'given invalid store instance' do
      subject { Process::JsonProcessor.new(nil, nil) }
      it 'gets initialized' do
        expect(subject).not_to be_nil
      end

      it 'initializes empty queue' do
        expect(subject.event_queue).not_to be_nil
        expect(subject.event_queue.length).to eql(0)
      end

      it 'returns false on validate' do
        expect(subject.valid?).to be_falsy
      end
    end

    context 'provided valid store instance' do
      let(:store) { double('simple store') }
      subject { Process::JsonProcessor.new(store, {}) }

      it 'gets initialized' do
        expect(subject).not_to be_nil
      end

      it 'initializes empty queue' do
        expect(subject.event_queue.length).to eql(0)
      end

      it 'returns true on validate' do
        expect(subject.valid?).to eql(true)
      end

      it 'start runs the processor and stop stops it' do
        processor = Process::JsonProcessor.new(store, {})
        expect(processor.stopped?).to eql(true)
        processor.start
        expect(processor.running?).to eql(true)
        processor.stop
        expect(processor.stopped?).to eql(true)
      end

      it 'processes an event from the queue' do
        with_processor_running do |processor, store|
          expect(store).to receive(:write).with("test\n").and_return(true)
          processor.event_queue << 'test'
          sleep(0.5)
        end
      end

      it 'processes events and writes in the same order as input' do
        with_processor_running do |processor, store|
          array = []
          allow(store).to receive(:write) do |val|
            array << val
          end
          required = []
          (1..3).each do |n|
            processor.event_queue << "test#{n}"
            required << "test#{n}\n"
          end
          sleep(0.5)
          expect(array).to match_array(required)
        end
      end

      it 'processes an event and returns a processed output'
    end
  end
end

def with_processor_running
  store = double('simple store')
  processor = Process::JsonProcessor.new(store, {})
  processor.start
  yield(processor, store)
  processor.stop
end
