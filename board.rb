require 'light'

class Board

  attr_reader :ticks_elapsed

  def initialize matrix, options={init_phase: 0}
    @matrix =     matrix
    @num_lights = matrix.first.count - 1
    @init_phase = options.fetch(:init_phase) { 0 }
    @state  =     []
    @ticks_elapsed = 0

    # instantiate fibers
    @lights = []
    @num_lights.times do |light|
      @lights[light] = Fiber.new { |states, init|
        TrafficLight.light_state( states_of_light(light),@init_phase )
      }
    end
  end

  def tick
    @ticks_elapsed += 1
    @num_lights.times do |light|
      @state[light] = @lights[light].resume
    end
  end

  def draw
    @lights.each_with_index do |l,idx|
      yield(idx, @state[idx])
    end
  end

  private
  def states_of_light(light)
    @matrix.map do |line|
      [ line[1+light], line[0].to_i ]
    end
  end

end
