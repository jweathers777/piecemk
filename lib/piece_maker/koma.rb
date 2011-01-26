module PieceMaker
  class Koma
    attr_reader :width, :height
    #
    #               O = (0,0)
    #  O________________________________   
    #  |               inner width      |    ^
    #  |                    |           |    |
    #  |                    |           |    |
    #  |               P2   |           |    |
    #  |               |    V           |    |
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
    #  |                                |    |
    #  |________________________________|    v
    #                                  
    #  <---------square-width----------->                                  
    #                                  
    #
    #  major_side = |P0-P1|
    #  minor_side = |P1-P2|
    #  theta = Angle P1-P0-P4
    #  phi = Angle P2-P1-P3

    SCALE = 33.918181818181814
    DIMENSIONS = [
       {
         :width => 22.5, :height => 27.0, 
         :major_side_length => 22.5, :theta => 1.413716694115407, 
         :minor_side_length => 9.087145770278516, :phi => 2.082703807444008
       },
       {
         :width => 23.5, :height => 28.0, 
         :major_side_length => 23.5, :theta => 1.413716694115407, 
         :minor_side_length => 9.387422993470103, :phi => 2.082703807444008
       },
       {
         :width => 25.5, :height => 29.0, 
         :major_side_length => 25.5, :theta => 1.413716694115407, 
         :minor_side_length => 9.555099861716837, :phi => 2.082703807444008
       },
       {
         :width => 26.7, :height => 30.0, 
         :major_side_length => 26.7, :theta => 1.413716694115407, 
         :minor_side_length => 9.864847316814341, :phi => 2.082703807444008
       },
       {
         :width => 27.7, :height => 31.0, 
         :major_side_length => 27.7, :theta => 1.413716694115407, 
         :minor_side_length => 10.189501615937441, :phi => 2.082703807444008
       },
       {
         :width => 28.7, :height => 32.0, 
         :major_side_length => 28.7, :theta => 1.413716694115407, 
         :minor_side_length => 10.515372151562836, :phi => 2.082703807444008
       }
    ]

    def self.calculate_minor_side_length(width, height, theta)
      edge_width = width*Math.cos(theta)
      inner_height = width*Math.sin(theta)

      inner_width = width - 2*edge_width
      top_height = height - inner_height
      top_half_width = inner_width/2

      Math.sqrt(top_height**2 + top_half_width**2)
    end

    def initialize(size, square_width, square_height)
      @index = size - 1
      @size = size
      
      @square_width = square_width
      @square_height = square_height
      
      @width = (DIMENSIONS[@index][:width] / SCALE) * @square_width
      @height = (DIMENSIONS[@index][:height] / SCALE) * @square_width
    end

    def inner_width
      @inner_width ||= self.vertices[6] - self.vertices[2]
    end
    
    def inner_height
      @inner_height ||= self.vertices[1] - self.vertices[3]
    end

    def vertices
      @vertices ||= 
        begin
          major_side_length = (DIMENSIONS[@index][:major_side_length] / SCALE) * @square_width
          minor_side_length = (DIMENSIONS[@index][:minor_side_length] / SCALE) * @square_width
          theta = DIMENSIONS[@index][:theta]
          phi = DIMENSIONS[@index][:phi]

          vertices = [0]*8
          vertices[0] = ((@square_width - @width)/2).to_i
          vertices[1] = ((@square_height + @height)/2).to_i

          vertices[8] = ((@square_width + @width)/2).to_i
          vertices[9] = vertices[1]
    
          vertices[2] = (vertices[0] + major_side_length * Math.cos(theta)).to_i
          vertices[3] = (vertices[1] - major_side_length * Math.sin(theta)).to_i
          
          vertices[6] = (vertices[8] - major_side_length * Math.cos(theta)).to_i
          vertices[7] = vertices[3]

          vertices[4] = (0.5*vertices[0] + 0.5*vertices[8]).to_i
          vertices[5] = (vertices[3] - minor_side_length*Math.sin(phi)).to_i

          vertices
        end
    end
  end
end
