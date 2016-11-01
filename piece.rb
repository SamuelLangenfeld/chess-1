module Chess

  class Piece
    attr_reader :team, :icon, :col, :row

    def initialize(team)
      @team = team
    end

    def clean(moves)
      cleaned = []
      moves.each do |move|
        cleaned << move if move[0].between?(0, 7) && move[1].between?(0, 7)
      end
      cleaned
    end
  end

  class Pawn < Piece
    attr_accessor :moved

    def initialize(team)
      super
      @icon = team == :W ? "\u2659" : "\u265F"
      @moved = false
    end

    def poss_moves(from_col, from_row)
      moves = []
      if @team == :W
        moves << [from_col, from_row + 1]
        moves << [from_col, from_row + 2] unless @moved
      else
        moves << [from_col, from_row - 1]
        moves << [from_col, from_row - 2] unless @moved
      end
      clean(moves)
    end
  end

  class Rook < Piece
    attr_accessor :moved

    def initialize(team)
      super
      @icon = team == :W ? "\u2656" : "\u265C"
      @moved = false
    end

    def poss_moves(from_col, from_row)
      moves = []
      0.upto(7) { |to_row| moves << [from_col, to_row] unless to_row == from_row }
      0.upto(7) { |to_col| moves << [to_col, from_row] unless to_col == from_col }
      clean(moves)
    end
  end

  class Knight < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2658" : "\u265E"
    end

    def poss_moves(from_col, from_row)
      moves = [[from_col + 1, from_row + 2], [from_col + 2, from_row + 1],
               [from_col + 2, from_row - 1], [from_col + 1, from_row - 2],
               [from_col - 1, from_row - 2], [from_col - 2, from_row - 1],
               [from_col - 2, from_row + 1], [from_col - 1, from_row + 2]]
      clean(moves)
    end
  end

  class Bishop < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2657" : "\u265D"
    end

    def poss_moves(from_col, from_row)
      moves = []
      to_col, to_row = from_col + 1, from_row + 1
      until (to_col > 7) || (to_row > 7)
        moves << [to_col, to_row]
        to_col += 1
        to_row += 1
      end
      to_col, to_row = from_col + 1, from_row - 1
      until (to_col > 7) || (to_row < 0)
        moves << [to_col, to_row]
        to_col += 1
        to_row -= 1
      end
      to_col, to_row = from_col - 1, from_row - 1
      until (to_col < 0) || (to_row < 0)
        moves << [to_col, to_row]
        to_col -= 1
        to_row -= 1
      end
      to_col, to_row = from_col + 1, from_row + 1
      until (to_col < 0) || (to_row > 7)
        moves << [to_col, to_row]
        to_col -= 1
        to_row += 1
      end
      moves
    end
  end

  class King < Piece
    attr_accessor :moved
    
    def initialize(team)
      super
      @icon = team == :W ? "\u2654" : "\u265A"
      @moved = false
    end

    def poss_moves(from_col, from_row)
      moves = [[from_col, from_row + 1], [from_col + 1, from_row + 1],
               [from_col + 1, from_row], [from_col + 1, from_row - 1],
               [from_col, from_row - 1], [from_col - 1, from_row - 1],
               [from_col - 1, from_row], [from_col - 1, from_row + 1]]
      clean(moves)
    end
  end

  class Queen < Piece
    def initialize(team)
      super
      @icon = team == :W ? "\u2655" : "\u265B"
    end

    def poss_moves(from_col, from_row)
      moves = []
      0.upto(7) { |to_row| moves << [from_col, to_row] unless to_row == from_row }
      0.upto(7) { |to_col| moves << [to_col, from_row] unless to_col == from_col }
      to_col, to_row = from_col + 1, from_row + 1
      until (to_col > 7) || (to_row > 7)
        moves << [to_col, to_row]
        to_col += 1
        to_row += 1
      end
      to_col, to_row = from_col + 1, from_row - 1
      until (to_col > 7) || (to_row < 0)
        moves << [to_col, to_row]
        to_col += 1
        to_row -= 1
      end
      to_col, to_row = from_col - 1, from_row - 1
      until (to_col < 0) || (to_row < 0)
        moves << [to_col, to_row]
        to_col -= 1
        to_row -= 1
      end
      to_col, to_row = from_col + 1, from_row + 1
      until (to_col < 0) || (to_row > 7)
        moves << [to_col, to_row]
        to_col -= 1
        to_row += 1
      end
      clean(moves)
    end
  end

end
