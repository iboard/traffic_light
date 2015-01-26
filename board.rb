require 'light'

class Board

  attr_reader :ticks_elapsed

  def initialize matrix, options={}
    @matrix        = matrix
    @num_lights    = matrix.first.count - 1
    @init_phase    = options.fetch(:init_phase) { 0 }
    @state         = []
    @ticks_elapsed = 0

    init_fibers
  end

  def tick
    @ticks_elapsed += 1
    @num_lights.times do |light|
      @state[light] = @lights[light].resume
    end
  end

  def lights_with_index
    @lights.each_with_index do |l,idx|
      yield(@state[idx],idx)
    end
  end

  private

  def init_fibers
    @lights = []
    @num_lights.times do |light|
      @lights[light] = Fiber.new { |states, init|
        TrafficLight.light_state( states_of_light(light),@init_phase )
      }
    end
  end

  def states_of_light(light)
    @matrix.map do |line|
      [ line[1+light], line[0].to_i ]
    end
  end

end
