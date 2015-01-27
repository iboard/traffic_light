module TrafficLight
  def self.state(states, init_phase = 0)
    current = 0  # states[current] => [ Label, number of ticks ]

    loop do
      label, ticks = states[current]
      ticks.times { Fiber.yield label }

      current += 1
      current = init_phase if current == states.count
    end
  end
end
