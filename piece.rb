module Chess

  class Piece
    attr_reader :team, :icon, :col, :row

    def initialize(team)
      @team = team
    end
  end

  class Pawn < Piece
    attr_accessor :moved

    def initialize(team)
      super
      @icon = team == :W ? "\u2659" : "\u265F"
      @moved = false
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

end
