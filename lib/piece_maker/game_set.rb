# encoding: UTF-8

require 'RMagick'
include Magick

module PieceMaker
  class GameSet
    @@config = Configuration.instance
    
    @@kanji_gc = Draw.new {
      self.encoding = 'Unicode'
      self.font = @@config.font
      self.gravity = CenterGravity
    }

    def initialize(name)
      @name = name
      @description = YAML.load_file("#{name}.yml")
      
      symbols = @description[:setup].join(',').split(',').
        uniq.map {|e| e.strip}.reject {|e| e == ''}
      @pieces = []
      @piece_information = {}
      @description[:pieces].each do |p|
        if symbols.include?(p[:notation])
          @pieces << p[:english]
        end
        @piece_information[p[:english]] = p
      end
    end

    def render_piece(piece, size, kanji_color, file_name)
      bg = @@config.colors[:background]
      image = Image.new(@@config.square_width, @@config.square_height) {
        self.background_color = bg
      }

      koma = Koma.new(size, @@config.square_width, @@config.square_height)
      draw_koma(image, koma)
      
      kanji = piece[:kanji].split(//).join("\n")
      draw_kanji(image, koma, kanji, kanji_color)

      image.write("png32:"+File.join(@name, "#{file_name}.png"))
    end

    def render_pieces
      Dir.mkdir(@name) unless Dir.exists?(@name)
      
      @pieces.each do |p|
        piece = @piece_information[p]
        render_piece(piece, piece[:size], @@config.colors[:kanji], piece[:english])
        if piece[:promotion]
          promoted_piece = @piece_information[piece[:promotion]]
          render_piece(promoted_piece, piece[:size], @@config.colors[:promoted_kanji], "promoted #{piece[:english]}")
        end
      end
    end

    def render_board
      tile = Image.read(@@config.tile).first
      width = @description[:dimensions][0] * @@config.square_width +
        (@description[:dimensions][0]+1) * @@config.grid_width + 
        2*@@config.side_border_width
      height = @description[:dimensions][1] * @@config.square_height +
        (@description[:dimensions][1]+1) * @@config.grid_width + 
        2*@@config.end_border_width

      image = Image.new(width, height)
      image.composite_tiled!(tile, ReplaceCompositeOp)

      gc = Draw.new
      gc.fill_opacity(0)
      gc.stroke(@@config.colors[:border])
      gc.stroke_width(2)

      x0 = @@config.side_border_width
      y0 = @@config.end_border_width

      xN = width - @@config.side_border_width - 2
      yN = height - @@config.end_border_width - 2

      x_delta = @@config.square_width + @@config.grid_width
      y_delta = @@config.square_height + @@config.grid_width

      (@description[:dimensions][1] + 1).times do |row|
        y = y0 + row*y_delta
        gc.line(x0, y, xN, y) 
      end
      
      (@description[:dimensions][0] + 1).times do |col|
        x = x0 + col*x_delta
        gc.line(x, y0, x, yN) 
      end

      if @description[:'zone-markers']
        offset = @description[:dimensions][1] + 1
        @description[:'zone-markers'].each do |marker|
          marker[0] = marker[0] - 1
          marker[1] = offset - marker[1]
          x = x0 + marker[0]*x_delta 
          y = y0 + marker[1]*y_delta
          radius = @@config.grid_width*3
          
          gc.fill_opacity(1)
          gc.fill(@@config.colors[:border])
          gc.circle(x,y,x-radius,y)
        end
      end

      gc.draw(image)
      image.write(File.join(@name, "board.png"))
    end

    private

    def draw_koma(image, koma)
      gc = Draw.new
      gc.fill_opacity(0)
      gc.stroke(@@config.colors[:border])
      gc.stroke_width(2)
      gc.fill(@@config.colors[:koma])
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
