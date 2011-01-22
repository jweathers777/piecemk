require 'singleton'
module PieceMaker
  class Configuration
    include Singleton

    def initialize
      @config = YAML.load_file('config.yml')
      @dpi = @config[:dimensions][:dpi].to_f
    end

    def games
      @config[:games]
    end

    def colors
      @config[:colors]
    end

    def square_width
      @square_width ||= convert_to_pixels(
        @config[:dimensions][:square][:width],
        @config[:dimensions][:square][:units]
      )
    end
    
    def square_height
      @square_height ||= convert_to_pixels(
        @config[:dimensions][:square][:height],
        @config[:dimensions][:square][:units]
      )
    end

    private
    def convert_to_pixels(measure, units)
      case units
      when 'inch'
        (measure * @dpi).to_i
      when 'cm'
        ((measure * @dpi) / 2.54).to_i
      end
    end
  end
end
