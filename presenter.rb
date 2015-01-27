require 'forwardable'

class Presenter
  extend Forwardable
  def_delegator :@display, :draw_lane
  def_delegator :@display, :center
  def_delegator :@display, :middle
  def_delegator :@display, :draw_light
  def_delegator :@display, :state
  def_delegator :@display, :text_at
  def_delegator :@display, :width

  def initialize(display)
    @display = display
  end

  def draw(light_group, light_state)
    send(light_group, light_state)
  end

  private

  def cars_north_south(light_state)
    draw_lane(center, middle - 10, center, middle + 10) if light_state == 'G--'
    draw_light(center - 1, middle - 1, light_state.reverse)
    draw_light(center - 1, middle + 1, light_state)
  end

  def pedestrians_north_south(light_state)
    draw_lane(center - 18, middle - 2, center - 18, middle + 2) if light_state == '-GO-'
    draw_lane(center + 22, middle - 2, center + 22, middle + 2) if light_state == '-GO-'

    draw_light(center - 20, middle - 2, light_state)
    draw_light(center - 20, middle + 2, light_state)
    draw_light(center + 20, middle - 2, light_state)
    draw_light(center + 20, middle + 2, light_state)
  end

  def center_light(light_state)
    draw_light(center, middle, light_state)
    case light_state
    when 'X'
      state 'Changing ...'
    when '|'
      state 'North-South: OPEN,    East-West: STOPPED'
    when '-'
      state 'North-South: STOPPED, East-West: OPEN'
    end
  end

  def cars_east_west(light_state)
    draw_lane(center - 20, middle, center + 23, middle) if light_state == 'G--'
    draw_light(center - 4, middle, light_state)
    draw_light(center + 2, middle, light_state.reverse)
  end

  def pedestrians_east_west(light_state)
    draw_lane(center - 10, middle - 5, center + 10, middle - 5) if light_state == '-GO-'
    draw_lane(center - 10, middle + 5, center + 10, middle + 5) if light_state == '-GO-'
    draw_light(center - 10, middle - 5, light_state)
    draw_light(center - 10, middle + 5, light_state)
    draw_light(center + 8, middle - 5, light_state)
    draw_light(center + 8, middle + 5, light_state)
  end

  def state_light(light_state)
    text_at(width - light_state.length - 2, 1, light_state)
  end
end
