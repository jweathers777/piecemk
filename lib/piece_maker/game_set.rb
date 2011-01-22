# encoding: UTF-8

require 'RMagick'
include Magick

module PieceMaker
  class GameSet
    @@kanji_gc = Draw.new {
      self.encoding = 'Unice'
      self.encoding = 'Unicode'
      self.font = '/System/Library/Fonts/儷黑 Pro.ttf'
      self.gravity = CenterGravity
    }

    def initialize(name)
      @name = name
      @description = YAML.load_file("#{name}.yml")
      @config = Configuration.instance
    end

    def render_pieces
      Dir.mkdir(@name) unless Dir.exists?(@name)
      
      @description[:pieces].each do |piece|
        image = Image.new(@config.square_width, @config.square_height)
        image.background_color = @config.colors[:background]

        koma = Koma.new(piece[:size], @config.square_width, @config.square_height)
        draw_koma(image, koma)
        
        kanji = piece[:kanji].split(//).join("\n")
        kanji_color = piece[:is_promoted] ? @config.colors[:promoted_kanji] : @config.colors[:kanji]
        draw_kanji(image, koma, kanji, kanji_color)

        image.write(File.join(@name, "#{piece[:english]}.png"))
      end
    end

    private

    def draw_koma(image, koma)
      gc = Draw.new
      gc.fill_opacity(0)
      gc.stroke(@config.colors[:border])
      gc.stroke_width(2)
      gc.fill(@config.colors[:koma])
      gc.polygon(*(koma.vertices))
      gc.draw(image)
    end

    def draw_kanji(image, koma, kanji, color)
      pointsize = koma.inner_height/2
      searching = true
      while searching
        @@kanji_gc.pointsize = pointsize
        m = @@kanji_gc.get_multiline_type_metrics(kanji)
        searching = (m.width > koma.inner_width or m.height > koma.inner_height)
        pointsize -= 1 if searching
      end

      @@kanji_gc.annotate(image, 0, 0, 0, 0, kanji) {
        self.fill = color
      }
    end
  end
end
