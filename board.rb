require 'light'

class Board
  class LoopTerminated < StandardError; end

  attr_reader :ticks_elapsed

  def initialize(matrix, options = {})
    @matrix        = matrix
    @num_lights    = matrix.first.count - 1
    @init_phase    = options.fetch(:init_phase) { 0 }
    @state         = []
    @ticks_elapsed = 0
    @loop          = options.fetch(:loop) { true }

    init_fibers
  end

  def tick
    @ticks_elapsed += 1
    light_ids { |idx| @state[idx] = @lights[idx].resume }
  end

  def lights_with_index
    @lights.each_with_index { |_fiber, idx| yield(@state[idx], idx) }
  end

  private

  def light_ids
    @num_lights.times { |n| yield(n) }
  end

  def init_fibers
    @lights = []
    light_ids  {|light| init_fiber(light) }
  end

  def init_fiber n
    @lights[n] = Fiber.new do |_states, _init|
      TrafficLight.state(states_of_light(n), @init_phase, @loop)
    end
  end

  def states_of_light(light)
    @matrix.map do |line|
      [line[1 + light], line[0].to_i]
    end
  end
end
