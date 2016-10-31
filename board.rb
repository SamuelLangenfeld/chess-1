module Chess
  COLS = %w{ A B C D E F G H }
  ROWS = (1..8).to_a.reverse

  class Board
    attr_reader :board

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

    def tutorial
      puts "Welcome to Chess!"
      puts "Move by entering board locations."
      puts "For example, move a pawn by entering D2 D4."
      puts "Checkmate your opponent to win."
      puts
    end

    def piece(col, row)
      return @board[col][row] if @board[col][row].is_a?(Piece)
      nil
    end

    def valid_move?(from_col, from_row, to_col, to_row)
      curr_piece = piece(from_col, from_row)
      return false if curr_piece.team == piece(to_col, to_row).team

      true
    end

    def has_straight_los?(from_col, from_row, to_col, to_row)                 
      if from_col == to_col
        from_row, to_row = to_row, from_row if from_row > to_row
        for row in from_row + 1...to_row
          return false unless piece(from_col, row).nil?
        end
      else
        from_col, to_col = to_col, from_col if from_col > to_col
        for col in from_col + 1...to_col
          return false unless piece(col, from_row).nil?
        end
      end
      true
    end

    def has_diag_los?(from_col, from_row, to_col, to_row)
      from_col, from_row = to_col, to_row if (from_col > to_col) && (from_row > to_row)
      if (from_col < to_col) && (from_row < to_row)
        col = from_col
        row = from_row
        until col == to_col && row == to_row
          col += 1
          row += 1
          return false unless piece(col, row).nil?
        end
      else
        from_col, from_row = to_col, to_row if (from_col > to_col) && (from_row < to_row)
        col = from_col
        row = from_row
        until col == to_col && row == to_row
          col += 1
          row -= 1
          return false unless piece(col, row).nil?
        end
      end
      true
    end

    def move(from_col, from_row, to_col, to_row)
      @board[to_col][to_row] = piece(from_col, from_row)
      if piece(to_col, to_row).is_a?(Pawn)
        piece(to_col, to_row).moved = true
      end
      @board[from_col][from_row] = nil
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
      return piece(col, row).icon if piece(col, row)
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
