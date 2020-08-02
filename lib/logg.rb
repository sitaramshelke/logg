require 'engine/engine'

class Logg
  def initialize
    @stopped = false
    @engine = nil
  end

  def start
    @engine = Engine::Core.new('./config.yml')
    @engine.setup
    @engine.start
    puts 'Started..'
    sleep 1 until @stopped
  rescue SystemExit, Interrupt
    puts 'Got exception..'
    stop
  end

  def stop
    @stopped = true
    @engine.stop
    puts 'Exiting..'
    exit(0)
  end
end