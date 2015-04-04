module TrafficLight
  class SingleRunMode < StandardError; end

  def self.state(states, init_phase = 0,looping = true)
    current = 0  # states[current] => [ Label, number of ticks ]

    loop do
      label, ticks = states[current]
      ticks.times { Fiber.yield label }

      current += 1
      if current == states.count
        raise TrafficLight::SingleRunMode unless looping
        current = init_phase
      end
    end
  end
end
