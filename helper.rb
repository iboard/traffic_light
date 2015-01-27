module Helpers
  COPYRIGHT = '©2015 by Andi Altendorfer'

  def slow_down(current)
    (current <= 0 ? 1 : current) * 2
  end

  def speed_up(current)
    current = current / 2 if current > 0
  end

  def read_matrix input
    input.split(/\n+/).map {|line|
      next if line =~ /^\s*#/
        line.split(/\s+/)[1..-1]
    }.to_a.compact
  end
end
