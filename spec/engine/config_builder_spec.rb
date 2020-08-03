require 'engine/engine'

describe Engine::ConfigBuilder do
  describe 'ConfigBuilder' do
    context 'when building outputs' do
      it 'will create an instance of BaseStore for each output'
    end

    context 'when building processes' do
      it 'will create an instance of BaseProcessor for each process'
    end

    context 'when building inputs' do
      it 'will create an instance of BaseInput for each input'
    end

  end
end
