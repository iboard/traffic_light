module TrafficLight

  def self.light_state v, init
    states  = v
    current = 0  # current pair

    loop do
      light_state,ticks = states[current]
      ticks.times do
        Fiber.yield light_state
      end
      current += 1
      current = init if current == states.count
    end
  end

end
