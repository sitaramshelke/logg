require 'engine/engine'

describe Engine::Core do
  describe 'Core' do
    context 'when provided config filepath' do
      it 'setup returns false if parse fails'
      it 'setup returns false if build fails'
      it 'setup returns true if parse and build succeeds'
    end

    context 'when starts' do
      it 'expects all inputs to be running'
      it 'expects all processes to be running'
    end

    context 'when stops' do
      it 'expects all inputs to be stopped'
      it 'expects all processes to be stopped'
    end
  end
end
