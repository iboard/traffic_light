require 'curses'
require 'light_color'

class Display
  include Curses; GW = Curses

  attr_reader :state, :title

  def initialize(title, board, copyright = COPYRIGHT)
    @state     = 'Initializing...'
    @board     = board
    @title     = title
    @copyright = copyright

    init_curses
  end

  def wait_key(timeout = 1_000)
    GW.timeout = timeout
    GW.getch
  end

  def draw
    clear
    yield
    park_cursor
    refresh
  end

  def draw_light(x, y, state)
    draw_light_state x, y, state
  end

  def draw_lane(x1, y1, x2, y2)
    draw_vertical(x1, y1, x2, y2)   if x1 == x2
    draw_horizontal(x1, y1, x2, y2) if y1 == y2
  end

  def center
    GW.cols / 2
  end

  def middle
    GW.lines / 2
  end

  def text_at(x, y, msg)
    draw_light_state(x, y, msg[0, 40])
  end

  def close
    win.close
    GW.close_screen
  end

  def width
    GW.cols
  end

  def height
    GW.lines
  end

  def state(new_state = @state)
    def filler
      ' ' * (GW.cols - @copyright.length - @state.length - 41)
    end

    win.attron(color_pair(COLOR_WHITE) | GW::A_REVERSE) do
      win.setpos GW.lines-1, 0
      win.addstr '%20s | %9d | %s %s' % [Time.now.to_s, ticks_elapsed, @state = new_state, filler]
    end
  end

  private

  def win
    @win ||= GW::Window.new(GW.lines, GW.cols, 0, 0)
  end

  def refresh
    win.refresh
  end

  def park_cursor
    win.setpos middle, center
  end

  def clear
    win.clear

    logo
    copyright
    state
    help
  end

  def init_curses
    GW.init_screen
    GW.curs_set(0)
    init_color
  end

  def init_color
    GW.start_color
    GW.init_pair(COLOR_RED,    COLOR_RED,    COLOR_BLACK)
    GW.init_pair(COLOR_GREEN,  COLOR_GREEN,  COLOR_BLACK)
    GW.init_pair(COLOR_RED,    COLOR_RED,    COLOR_BLACK)
    GW.init_pair(COLOR_YELLOW, COLOR_YELLOW, COLOR_BLACK)
    GW.init_pair(COLOR_BLACK,  COLOR_BLACK,  COLOR_BLACK)
    GW.init_pair(COLOR_WHITE,  COLOR_WHITE,  COLOR_BLACK)
    GW.init_pair(COLOR_CYAN,   COLOR_CYAN,   COLOR_BLACK)
    GW.init_pair(COLOR_BLUE,   COLOR_BLUE,   COLOR_BLACK)

    @light_colors =
      {
        cyan:   COLOR_CYAN,
        red:    COLOR_RED,
        green:  COLOR_GREEN,
        black:  COLOR_BLACK,
        white:  COLOR_WHITE,
        orange: COLOR_YELLOW,
        blue:   COLOR_BLUE
      }
  end

  def draw_light_state(x, y, state)
    state.chars.each_with_index do |_c, idx|
      win.setpos y, x + idx
      output_color_char_at(state, idx)
    end
  end

  def output_color_char_at(state, idx)
    color = LightColor.new(idx, state, @light_colors).to_i
    char_with_color(state[idx],color)
  end

  def ticks_elapsed
    @board.ticks_elapsed
  end

  def logo
    win.setpos 0, 0
    win.addstr title
  end

  def help
    output_lines_at(GW.lines - 10, 2, <<-EOT.gsub(/^\s{6}/, ''))
      _____________________________________
      Keys:
       + ... Double Tick length (slow down)
       - ... Half Tick length (speed up)
       = ... Reset tick-length to 1000ms
       q ... quit
      _____________________________________
    EOT
  end

  def output_lines_at(y, x, txt)
    txt.each_line.each_with_index do |l, idx|
      win.setpos y + idx, x
      win.addstr l
    end
  end

  def copyright
    win.attron(color_pair(COLOR_WHITE) | GW::A_REVERSE) do
      win.setpos GW.lines-1, GW.cols - @copyright.length
      win.addstr @copyright
    end
    @copyright
  end

  def draw_vertical(x1, y1, _x2, y2)
    (y1..y2).each {|y| char_at y,x1,'.' }
  end

  def draw_horizontal(x1, y1, x2, _y2)
    (x1..x2).each {|x| char_at y1,x,'.' }
  end

  def char_at(y,x,char='.', color=nil)
    win.setpos y, x
    color ? char_with_color(char,color) : put_char(char)
  end

  def char_with_color(char,color)
    win.attron(color_pair(color) | GW::A_NORMAL) { put_char(char) }
  end

  def put_char(char)
    win.addstr char
  end
end
