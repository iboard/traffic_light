class LightColor

  def initialize(idx, state, mapping)
    @idx = idx
    @state = state
    @mapping = mapping
    @color = color_at(idx)
  end

  def to_i
    @mapping[@color] || @mapping.first[1]
  end

  private

  def color_at(idx)
    case @state
    when 'STOP', /^R-|-R$/, 'on-all-stopped', 'off'
      @state[idx] == '-' ? :white : :red
    when '-GO-', '*--', '--*', /^G|G$/, /on-east-west/, /on-north-south/
      @state[idx] == '-' ? :white : :green
    when '*GO*', /stopping/, /starting/
      :orange
    else
      case @state[idx]
      when '-' then :blue
      when 'R' then :red
      when 'O' then :orange
      when 'G' then :green
      when '*' then :orange
      else
        :black
      end
    end
  end
end
