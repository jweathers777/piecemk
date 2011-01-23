$: << File.expand_path('lib')

require 'rubygems'
require 'yaml'
require 'piece_maker'

config = PieceMaker::Configuration.instance

config.games.each do |name|
  game_set = PieceMaker::GameSet.new(name)
  game_set.render_pieces
  game_set.render_board
end
