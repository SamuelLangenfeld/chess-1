require "yaml"

require "./board"
require "./piece"
require "./game"

include Chess
Game.new.play
