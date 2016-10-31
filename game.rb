module Chess

  class Game
    def initialize
      @game = Board.new
    end

    def play
      tutorial
      until @game_over
        turn
      end
    end

    private

    def turn
    end
  end

end
