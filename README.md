# Traffic Light Controller

A trafffic-light controller using Ruby, Fibers, and Curses

## Run it

  1. git clone https://github.com/iboard/traffic_light.git
  2. cd traffic_light
  3. bundle
  4. ./traffic_light

## Source

### Define a light-group

  1. Define a 'light-group' within the light_groups hash in
  `traffic_light.rb` as a symbol.
  2. Define a method in presenter.rb with the same name which is
  responsible to draw that light-group on the `Display`

### Understanding

  * The 'Matrix' is defined as an array of 'state-lines'
  * a 'state-line' is an array with the number of ticks this state holds
    in the first column followed by a string for each light-group.

                | Ticks G1  G2    G3 G4   G5     G6
        --------+-----------------------------------------------------
        State 1 |   8  --R  STOP  -  G--  -GO-   on-east-west
        State 2 |   2  --R  STOP  X  *--  #GO#   on-stopping-east-west
        State 3 |   2  --R  STOP  X  -O-  STOP   on-stopping-east-west
        State 4 |   4  --R  STOP  X  --R  STOP   on-all-stopped

  * `Board` initializes an array of `Fiber`s (one for each light-group)
  * Each of this Fibers yields to `TrafficLight.state()`
  * A call to `board.tick()` calls `resume` on each of the Fibers
  * The state of a fiber holds the array of states of a light-group
    and the 'current' position.
  * On each `resume` a fiber shifts the current position and resets it
    on overflow.
  * The `Presenter` knows how to draw the elements (lights, lanes, ...)
    using a `Display` for the low level drawing with `Curses`

Have Fun!
