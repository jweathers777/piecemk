module PieceMaker
  class Koma
    attr_reader :width, :height, :inner_width, :inner_height, :top_height
    #
    #               O = (0,0)
    #  O________________________________   
    #  |          inner width           |    ^
    #  |        <-------------->        |    |
    #  |                                |    |
    #  |               P2               |    |
    #  |               |                |    |
    #  |       P1------|-------P3       |    |
    #  |               |       |        |    |
    #  |               |       |        |    |
    #  |               |       | inner  |    |   square height
    #  |       height  |       | height |    |
    #  |               |       |        |    |
    #  |               |       |        |    |
    #  |               |       |        |    |
    #  |               |       |        |    |
    #  |   P0          |       |   P4   |    |
    #  |   <---------width---------->   |    |
    #  |            edge width <---->   |    |
    #  |________________________________|    v
    #                                  
    #  <---------square-width----------->                                  
    #                                  
    #
    #  major_side = |P0-P1|
    #  minor_side = |P1-P2|
    #  theta = Angle P1-P0-P4
    #  phi = Angle P2-P1-P3

    SCALE = 2.6
    DIMENSIONS = [
       {
         :width => 1.76, :height => 2.17, :major_side_length => 1.74, 
         :theta => 81.50, :phi => 122.13
       },
       {
         :width => 1.84, :height => 2.24, :major_side_length => 1.82, 
         :theta => 81.50, :phi => 122.13
       },
       {
         :width => 2.00, :height => 2.33, :major_side_length => 1.98, 
         :theta => 81.50, :phi => 122.13
       },
       {
         :width => 2.09, :height => 2.41, :major_side_length => 2.07, 
         :theta => 81.50, :phi => 122.13
       },
       {
         :width => 2.17, :height => 2.49, :major_side_length => 2.15, 
         :theta => 81.50, :phi => 122.13
       },
       {
         :width => 2.25, :height => 2.57, :major_side_length => 2.23, 
         :theta => 81.50, :phi => 122.13
       }
    ]

    def initialize(size, square_width, square_height)
      @index = size - 1
      @size = size
      
      @square_width = square_width
      @square_height = square_height

      @width = (DIMENSIONS[@index][:width] / SCALE) * @square_width
      @height = (DIMENSIONS[@index][:height] / SCALE) * @square_width

      @major_side_length = (DIMENSIONS[@index][:major_side_length] / SCALE) * @square_width
      @theta = DIMENSIONS[@index][:theta]*Math::PI/180.0
      @phi = DIMENSIONS[@index][:phi]*Math::PI/180.0
      @alpha = @theta + @phi + Math::PI

      @edge_width = (@major_side_length * Math.cos(@theta)).to_i

      @inner_width = @width - 2*@edge_width
      @inner_height = (@major_side_length * Math.sin(@theta)).to_i
      @top_height = (0.5*@inner_width*Math.tan(@alpha)).to_i
    end


    def vertices
      @vertices ||= 
        begin
          vertices = [0]*8
          #P0
          vertices[0] = ((@square_width - @width)/2).to_i
          vertices[1] = ((@square_height + @height)/2).to_i

          #P4
          vertices[8] = ((@square_width + @width)/2).to_i
          vertices[9] = vertices[1]
    
          #P1
          vertices[2] = vertices[0] + @edge_width 
          vertices[3] = vertices[1] - @inner_height
          
          #P3
          vertices[6] = vertices[8] - @edge_width 
          vertices[7] = vertices[3]

          #P2
          vertices[4] = ((vertices[0] + vertices[8])/2).to_i
          vertices[5] = vertices[3] - @top_height

          vertices
        end
    end
  end
end
