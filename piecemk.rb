# encoding: UTF-8

require 'yaml'
require 'rubygems'
require 'RMagick'

include Magick 

piece_color = 'rgb(229,194,117)'
border_color = 'black'
kanji_color = 'black'
promoted_color = 'rgb(198, 33, 57)'

board_width_in_squares = 9
square_width = 54
square_height = ((4.0*square_width)/3.5).to_i
grid_width = 2

class Koma
  attr_reader :inner_width, :inner_height, :vertices

  SCALE = 3.3114754098360657
  DIMENSIONS = [
     { 
       :width => 2.0, :height => 2.1784967336952059, 
       :major_side_length => 2.2, :major_side_angle => 1.4308665149210393, 
       :minor_side_length => 0.7, :minor_side_angle => 0.13992981187385722 
     },
     {
       :width => 2.2, :height => 2.3646668685905188, 
       :major_side_length => 2.4, :major_side_angle => 1.3989917626074015, 
       :minor_side_length => 0.7, :minor_side_angle => 0.17978546233291781
     },
     {
       :width => 2.3, :height => 2.2716747920588776, 
       :major_side_length => 2.3, :major_side_angle => 1.4136933736338848, 
       :minor_side_length => 0.8, :minor_side_angle => 0.15710295316101175
     },
     {
       :width => 2.5, :height => 2.5246081695959628, 
       :major_side_length => 2.55, :major_side_angle => 1.4295578749398743, 
       :minor_side_length => 0.9, :minor_side_angle => 0.14123845185502226
     },
     {
       :width => 2.6, :height => 2.6825511579847716, 
       :major_side_length => 2.7, :major_side_angle => 1.4570465415216347, 
       :minor_side_length => 1.0, :minor_side_angle => 0.11374978527326185
     },
     {
       :width => 2.8, :height => 2.7696976484401667, 
       :major_side_length => 2.8, :major_side_angle => 1.4235424970034918, 
       :minor_side_length => 1.0, :minor_side_angle => 0.14725382979140478
     }
  ]

  def initialize(size, width, height)
    @index = size - 1
    @size = size
    @width = width
    @height = height
  end

  def inner_width
    @inner_width ||= (DIMENSIONS[@index][:width] / SCALE) * @width
  end
  
  def inner_height
    @inner_height ||= (DIMENSIONS[@index][:height] / SCALE) * @width
  end

  def vertices
    #
    #               O = (0,0)
    #  O________________________________   
    #  |                                |    ^
    #  |                                |    |   major_side = |P0-P1|
    #  |                                |    |   minor_side = |P1-P2|
    #  |               P2               |    |
    #  |               |                |    |   major_side_angle = Angle P1-P0-P4
    #  |       P1      |       P3       |    |   minor_side_angle = Angle P2-P1-P3
    #  |               |                |    |
    #  |               |                |    |
    #  |               |                |    |   square height
    #  |       height  |                |    |
    #  |               |                |    |
    #  |               |                |    |
    #  |               |                |    |
    #  |               |                |    |
    #  |   P0          |           P4   |    |
    #  |   <---------width---------->   |    |
    #  |                                |    |
    #  |________________________________|    v
    #                                  
    #  <---------square-width----------->                                  
    #                                  
    #

    @vertices ||= 
      begin
        width = (DIMENSIONS[@index][:width] / SCALE) * @width
        height = (DIMENSIONS[@index][:height] / SCALE) * @width
        major_side_length = (DIMENSIONS[@index][:major_side_length] / SCALE) * @width
        minor_side_length = (DIMENSIONS[@index][:minor_side_length] / SCALE) * @width
        major_side_angle = DIMENSIONS[@index][:major_side_angle]
        minor_side_angle = DIMENSIONS[@index][:minor_side_angle]

        vertices = [0]*8
        vertices[0] = ((@width - width)/2).to_i
        vertices[1] = ((@height + height)/2).to_i

        vertices[8] = ((@width + width)/2).to_i
        vertices[9] = vertices[1]
  
        vertices[2] = (vertices[0] + major_side_length * Math.cos(major_side_angle)).to_i
        vertices[3] = (vertices[1] - major_side_length * Math.sin(major_side_angle)).to_i
        
        vertices[6] = (vertices[8] - major_side_length * Math.cos(major_side_angle)).to_i
        vertices[7] = vertices[3]

        vertices[4] = (0.5*vertices[0] + 0.5*vertices[8]).to_i
        vertices[5] = (vertices[3] - minor_side_length*Math.sin(minor_side_angle)).to_i

        vertices
      end
  end
end

def get_point_size(gc, text, width, height)
  pointsize = height/2
  searching = true
  while searching
    gc.pointsize = pointsize
    m = gc.get_multiline_type_metrics(text)
    searching = (m.width > width or m.height > height)
    pointsize -= 1 if searching
  end
  pointsize
end

kanji_gc = Draw.new
kanji_gc.encoding = 'Unicode'
kanji_gc.font = '/System/Library/Fonts/儷黑 Pro.ttf'
kanji_gc.gravity = CenterGravity

game = YAML.load_file('shogi.yml')

game[:pieces].each do |piece|
  image = Image.new(square_width, square_height) {self.background_color = 'white'}
  
  kanji = piece[:kanji].split(//).join("\n")
  shape = Koma.new(piece[:size], square_width, square_height)
  text_color = piece[:is_promoted] ? promoted_color : kanji_color

  koma = Draw.new
  koma.fill_opacity(0)
  koma.stroke(border_color)
  koma.stroke_width(2)
  koma.fill(piece_color)
  koma.polygon(*(shape.vertices))
  koma.draw(image)
  
  kanji_gc.pointsize = get_point_size(kanji_gc, kanji, shape.inner_width, shape.inner_height)
  kanji_gc.annotate(image, 0, 0, 0, 0, kanji){
    self.fill = text_color
  }
  image.write("#{piece[:english]}.png")
end

exit
