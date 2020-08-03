require 'engine/engine'

describe Engine::ConfigParser do
  describe 'ConfigParser' do
    it 'returns false when parsing an invalid filepath'
    it 'returns false when parsing a non exitent file'
    it 'returns false when it doesnt have read permissions for config file'

    it 'returns false if the config does not have inputs section'
    it 'returns false if the inputs does not have at least one input'
    it 'returns false if the config does not have processes section'
    it 'returns false if the inputs does not have at least one process'
    it 'returns false if the config does not have outputs section'
    it 'returns false if the inputs does not have at least one output'
  end
end
