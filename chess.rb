require "yaml"

module Chess

  class Piece
    # track location

    # move set
  end

  class Board
    COLS = %w{ A B C D E F G H }
    ROWS = (1..8).to_a.reverse

    def initialize
      @board = Array.new(8) { Array.new(8) }
    end

    def draw
      puts
      draw_board_top
      ROWS.each do |row|
        bkg = row.even? ? [" ", "\u2592"] : ["\u2592", " "]
        draw_row_filler(bkg)
        draw_row_content(row, bkg)
        draw_row_filler(bkg)
        draw_row_divider unless row == 1
      end
      draw_board_bottom
      puts
    end

    def draw_board_top
      puts "       #{COLS.join('       ')}"
      puts "   \u250C" + ("\u2500" * 7 + "\u252C") * 7 + "\u2500" * 7 + "\u2510"
    end

    def draw_row_filler(bkg)
      puts "   " + ("\u2502" + "#{bkg[0]}" * 7 + "\u2502" + "#{bkg[1]}" * 7) * 4 + "\u2502"
    end

    def draw_row_content(row, bkg)
      puts " #{row} " + ("\u2502" + "#{bkg[0]}" * 7 + "\u2502" + "#{bkg[1]}" * 7) * 4 + "\u2502" + " #{row}"
    end

    def draw_row_divider
      puts "   \u251C" + ("\u2500" * 7 + "\u253C") * 7 + "\u2500" * 7 + "\u2524"
    end

    def draw_board_bottom
      puts "   \u2514" + ("\u2500" * 7 + "\u2534") * 7 + "\u2500" * 7 + "\u2518"
      puts "       #{COLS.join('       ')}"
    end
  end

end

include Chess
game = Board.new
game.draw
