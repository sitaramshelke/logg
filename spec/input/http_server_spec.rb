require 'input/http_server'

describe Input::HTTPServer do
  describe 'HTTPServer' do
    context 'given invalid host or port' do
      it 'gets initialized'
      it 'cannot be started'
      it 'returns false on validate'
    end

    context 'given non existent event_queue' do
      it 'gets initialized'
      it 'cannot be started'
      it 'returns false on validate'
    end

    context 'given valid config' do
      it 'gets initialized'
      it 'cannot start if port already blocked'
      it 'returns true on validate'
      it 'returns 401 if empty event'
      it 'returns 401 if invalid json body'
      it 'returns 200 for a valid event'
      it 'writes event into queue'
      it 'appends event into queue'
      it 'stops after executing stop command'
    end

  end
end
