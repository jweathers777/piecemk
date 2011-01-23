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

    def font
      @config[:font]
    end

    def tile
      @tile ||= File.expand_path(@config[:tile])
    end

    %w{square:width square:height grid:width end_border:width side_border:width}.each do |pair|
      label, dimension = pair.split(':')
      name = "#{label}_#{dimension}"
      eval """
      define_method name do
        @#{name} ||= convert_to_pixels(
          @config[:dimensions][:#{label}][:#{dimension}],
          @config[:dimensions][:#{label}][:units]
        )
      end
      """
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
