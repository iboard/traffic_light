#!/usr/bin/env ruby -I.

require 'helper';    include Helpers
require 'board'      # Logic
require 'display'    # 'Draw' with Curses
require 'presenter'  # Knows how to draw lanes and lights

# Define Data

## Traffic LightGroups index
light_groups = {
  0 => :cars_north_south,
  1 => :pedestrians_north_south,
  2 => :center_light,
  3 => :cars_east_west,
  4 => :pedestrians_east_west,
  5 => :state_light
}


MATRIX = read_matrix <<-EOM
  #T CNS  PNS C CEW  PEW  State-Display
  # Init phase ...
  4 -*-  -**-  X   -*-  -**-   off
  2 -O-  STOP  X   -*-  -**-   off-starting
  2 --R  STOP  X   -*-  -**-   on-ready
  # Regular, loop
  8 --R  STOP  -   G--  -GO-   on-east-west
  2 --R  STOP  X   *--  *GO*   on-stopping-east-west
  2 --R  STOP  X   -O-  STOP   on-stopping-east-west
  4 --R  STOP  X   --R  STOP   on-all-stopped
  2 -OR  -GO-  |   --R  STOP   on-starting-north-south
  8 G--  -GO-  |   --R  STOP   on-north-south
  2 *--  *GO*  X   --R  STOP   on-stopping-north-south
  2 -O-  STOP  X   --R  STOP   on-stopping-north-south
  4 --R  STOP  X   --R  STOP   on-all-stopped
  2 --R  STOP  -   -OR  -GO-   on-starting-east-west
  EOM

# Config
tick     = 1_000 # length of a tick in ms


# Initialize
board    = Board.new(MATRIX, init_phase: 3)
display  = Display.new('Traffic Light, V0.1', board)
layout   = Presenter.new(display)

# Run
board.tick # required to set a defined state for 1st display
loop do

  # redraw the board
  display.draw do
    board.lights_with_index do |state, light_idx|
      # state
      #    .... A String, representing the current state
      #         of the light at light_idx
      # light_idx
      #    .... 0 based index in light_groups

      # get the light-group name (method name to be
      # called in layout
      light_group = light_groups[light_idx]

      # Let the presenter draw the given light_group
      # with the given state
      layout.draw light_group, state
    end
  end

  case display.wait_key(tick)
  when 'q' then break
  when '+' then tick = slow_down(tick)
  when '-' then tick = speed_up(tick)
  when '=' then tick = 1_000 # reset
  else
    board.tick
  end

end
display.close
puts display.title + ' terminated sucessfully'
