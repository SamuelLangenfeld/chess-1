require "yaml"

module Chess
  COLS = %w{ A B C D E F G H }
  ROWS = (1..8).to_a.reverse


  class Piece
    attr_reader :team, :icon, :col, :row

    def initialize(team)
      @team = team
    end
  end

  class Pawn < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2659" : "\u265F"
    end
  end

  class Rook < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2656" : "\u265C"
    end
  end

  class Knight < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2658" : "\u265E"
    end
  end

  class Bishop < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2657" : "\u265D"
    end
  end

  class King < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2654" : "\u265A"
    end
  end

  class Queen < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2655" : "\u265B"
    end
  end


  class Board
    def initialize
      @board = Array.new(8) { Array.new(8) }
      0.upto(7) do |col|
        @board[col][1] = Pawn.new(:W)
        @board[col][6] = Pawn.new(:B)
      end
      [0, 7].each do |col|
        @board[col][0] = Rook.new(:W)
        @board[col][7] = Rook.new(:B)
      end
      [1, 6].each do |col|
        @board[col][0] = Knight.new(:W)
        @board[col][7] = Knight.new(:B)
      end
      [2, 5].each do |col|
        @board[col][0] = Bishop.new(:W)
        @board[col][7] = Bishop.new(:B)
      end
      @board[3][0] = King.new(:W)
      @board[3][7] = King.new(:B)
      @board[4][0] = Queen.new(:W)
      @board[4][7] = Queen.new(:B)
    end

    def draw
      puts
      draw_board_top
      bkg = [" ", "\u2592"]
      ROWS.each_with_index do |row|
        bkg = bkg.reverse
        draw_row_filler(bkg)
        draw_row_content(row, bkg)
        draw_row_filler(bkg)
      end
      draw_board_bottom
      puts
    end

    def draw_piece(col, row)
      return @board[col][row].icon if @board[col][row].is_a?(Piece)
      return "\u2592" if col.odd? && row.even?
      return "\u2592" if col.even? && row.odd?
      " "
    end

    def draw_board_top
      puts "       #{COLS.join('      ')}"
      puts "   \u250C" + ("\u2500" * 7) * 8 + "\u2510"
    end

    def draw_row_filler(bkg)
      puts "   " + "\u2502" + ("#{bkg[0]}" * 7 + "#{bkg[1]}" * 7) * 4 + "\u2502"
    end

    def draw_row_content(row, bkg)
      print " #{row} " + "\u2502"
      0.upto(7) do |col|
        next unless col.even?
        print ("#{bkg[0]}" * 3 + draw_piece(col, row - 1) + "#{bkg[0]}" * 3)
        print ("#{bkg[1]}" * 3 + draw_piece(col + 1, row - 1) + "#{bkg[1]}" * 3)
      end
      print "\u2502" + " #{row}\n"
    end

    def draw_board_bottom
      puts "   \u2514" + ("\u2500" * 7) * 8 + "\u2518"
      puts "       #{COLS.join('      ')}"
    end
  end


  def translate_from(location)
    board_loc = []
    COLS.each_with_index do |col, index|
      board_loc << index if col == location[0]
    end
    board_loc << location[1].to_i - 1 if location[1].to_i.between?(1, 8)
    return board_loc if board_loc.size == 2
    nil
  end

end

include Chess
game = Board.new
game.draw
