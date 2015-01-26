require 'curses'

class Display
  include Curses

  attr_reader :state, :copyright, :title

  def initialize title, board, copyright="©2015 by Andi Altendorfer"
    @last_command = nil
    @state = 'initializing...'
    @board = board
    @title = title
    @copyright = copyright

    Curses.init_screen()
    init_color
    @win = Curses::Window.new( Curses.lines, Curses.cols, 0, 0 )
  end

  def init_color
    Curses.start_color
    Curses.init_pair(COLOR_RED,   COLOR_RED,   COLOR_RED)
    Curses.init_pair(COLOR_GREEN, COLOR_GREEN, COLOR_BLACK)
    Curses.init_pair(COLOR_RED,   COLOR_RED,   COLOR_BLACK)
    Curses.init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)
    Curses.init_pair(COLOR_BLACK, COLOR_BLACK, COLOR_WHITE)
    Curses.init_pair(COLOR_WHITE, COLOR_WHITE, COLOR_BLACK)
  end

  def wait_key(timeout=1_000)
    Curses.timeout = timeout
    Curses.getch
  end

  def draw
    clear
    yield
    @win.setpos middle, center
    refresh
  end

  def clear
    @win.clear

    logo
    copyright
    state
    help
    @win.box '|', '-'
  end

  def draw_light x, y, state
    draw_light_state x, y, state
  end

  def draw_lane x1,y1,x2,y2
    draw_vertical(x1,y1,x2,y2)   if x1 == x2
    draw_horizontal(x1,y1,x2,y2) if y1 == y2
  end

  def refresh
    @win.refresh
  end

  def center
    Curses.cols / 2
  end

  def middle
    Curses.lines / 2
  end

  def state(new_state=@state)

    def filler
      l = Curses.cols - @copyright.length - 33 - @state.length - 15
      " "*l
    end

    @win.setpos Curses.lines-2, 1
    @win.addstr "%20s | %9d | %s %s" % [ Time.now.to_s(), ticks_elapsed, @state = new_state, filler ]
  end

  def text_at x, y, msg
    draw_light_state( x, y, msg[0..40] )
  end

  def close
    @win.close
    Curses.close_screen
  end

  def width
    Curses.cols
  end

  def height
    Curses.lines
  end

  private

  def draw_light_state x, y, state
    state.chars.each_with_index do |c,idx|
      @win.setpos y, x+idx
      put_with_color_of_state_pos(state,idx)
    end
  end

  def put_with_color_of_state_pos(state,idx)
    color = case state
            when 'STOP', /^R-|-R$/, 'on-all-stopped', 'off'
              Curses::COLOR_RED
            when '-GO-', '*--', '--*', /^G|G$/, /on-east-west/, /on-north-south/
              Curses::COLOR_GREEN
            when '*GO*', /stopping/, /starting/
              Curses::COLOR_YELLOW
            else
              case state[idx]
              when ?-
                Curses::COLOR_BLUE
              when ?R
                Curses::COLOR_RED
              when ?O
                Curses::COLOR_YELLOW
              when ?G
                Curses::COLOR_GREEN
              when ?*
                Curses::COLOR_YELLOW
              else
                Curses::COLOR_BLACK
              end
            end
    @win.attron(color_pair(color)|Curses::A_REVERSE) do
      @win.addstr(state[idx])
    end
  end

  def ticks_elapsed
    @board.ticks_elapsed
  end

  def logo
    @win.setpos 1, 1
    @win.addstr @title
  end

  def help
    @win.setpos Curses.lines-10, 5
    @win.addstr 'Keys:'
    @win.setpos Curses.lines-9, 5
    @win.addstr '+ ... Double Tick length (slow down)'
    @win.setpos Curses.lines-8, 5
    @win.addstr '- ... Half Tick length (speed up)'
    @win.setpos Curses.lines-7, 5
    @win.addstr '= ... Reset tick-length to 1000ms'
    @win.setpos Curses.lines-6, 5
    @win.addstr 'q ... quit'
  end

  def copyright
    @win.setpos Curses.lines-2, Curses.cols - 1 - @copyright.length
    @win.addstr @copyright
  end

  def draw_vertical x1, y1, x2, y2
    for y in (y1..y2)
      @win.setpos y, x1
      @win.addstr "."
    end
  end

  def draw_horizontal x1, y1, x2, y2
    for x in (x1..x2)
      @win.setpos y1, x
      @win.addstr "."
    end
  end
end


