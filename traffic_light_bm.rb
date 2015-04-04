#!/usr/bin/env ruby -I.

require 'benchmark'
require 'helper';    include Helpers
require 'board'      # Logic
require 'display'    # 'Draw' with Curses
require 'presenter'  # Knows how to draw lanes and lights

# Define Data

# Traffic LightGroups index
def light_groups
  {
    0 => :cars_north_south,
    1 => :pedestrians_north_south,
    2 => :center_light,
    3 => :cars_east_west,
    4 => :pedestrians_east_west,
    5 => :state_light
  }
end


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

module NilCurses
  A_REVERSE = 0
  A_NORMAL  = 0

  def self.lines; 10; end
  def self.cols; 10; end
  class Window
    def initialize(*_)
    end
    def method_missing(name, *args)
    end
  end
  def self.method_missing(name,*args)
  end
end

def run_loop
  board    = Board.new(MATRIX, init_phase: 3, loop: false)
  display  = Display.new('Traffic Light, V0.1', board, NilCurses, "BM TEST")
  layout   = Presenter.new(display)

  # Run
  tick     = 0.001 # length of a tick in ms
  begin
    board.tick # required to set a defined state for 1st display
    loop do

      # redraw the board
      display.draw do
        board.lights_with_index do |state, light_idx|
          light_group = light_groups[light_idx]
          layout.draw light_group, state
        end
      end

      board.tick
    end
  rescue TrafficLight::SingleRunMode
    # noop
  end
end

# Initialize
Benchmark.bm(20) do |x|
  x.report('fibers:')       { run_loop }
  x.report('conservative:') { run_loop }
end


