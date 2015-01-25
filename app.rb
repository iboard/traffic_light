require 'pp'
require 'pry'

require 'board'
require 'renderer'
require 'layout'


# Define Data

## Traffic Light index
index = {
  0 => :cars_north_south,
  1 => :pedestrians_north_south,
  2 => :center_light,
  3 => :cars_east_west,
  4 => :pedestrians_east_west,
  5 => :state_light
}

MATRIX = [
 #   T CNS   PNS   CEW  PEW         # T ... Repeat for n Ticks
 # Init phase ...
 %w( 4 -*-  -**- X -*-  -**- off),
 %w( 2 -O-  STOP X -*-  -**- off-starting),
 %w( 2 --R  STOP X -*-  -**- on-ready),
 # Regular, loop
 %w( 8 --R  STOP - G--  -GO- on-east-west),
 %w( 2 --R  STOP X *--  *GO* on-stopping-east-west),
 %w( 2 --R  STOP X -O-  STOP on-stopping-east-west),
 %w( 4 --R  STOP X --R  STOP on-all-stopped),
 %w( 2 -OR  -GO- | --R  STOP on-starting-north-south),
 %w( 8 G--  -GO- | --R  STOP on-north-south),
 %w( 2 *--  *GO* X --R  STOP on-stopping-north-south),
 %w( 2 -O-  STOP X --R  STOP on-stopping-north-south),
 %w( 4 --R  STOP X --R  STOP on-all-stopped),
 %w( 2 --R  STOP - -OR  -GO- on-starting-east-west),
]

# Config
tick     = 1_000 #ms

# Initialize
board    = Board.new(MATRIX,3)
renderer = Renderer.new("Traffic Light, V0.1",board)
layout   = Layout.new(renderer)

# Run
board.tick
loop do

  # redraw the board
  renderer.draw do
    board.draw do |light_idx, state|
      light_group = index[light_idx]
      layout.draw light_group, state
    end
  end

  case renderer.wait_key(tick)
  when ?q
    break
  when ?+
    tick = (tick <= 0 ? 1 : tick) * 2
  when ?-
    tick = tick / 2 if tick > 0
  when ?=
    tick = 1_000
  else
    board.tick
  end

end
renderer.close
puts renderer.title + ' terminated sucessfully'





