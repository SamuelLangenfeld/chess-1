require_relative "../chess"

include Chess

describe Chess do

  describe "#parse" do
    it "parses input into board locations" do
      string = "D2 E3"
      expect(parse(string)).to eql(["D2", "E3"])
    end

    it "ignores spaces" do
      string = "D2E3"
      expect(parse(string)).to eql(["D2", "E3"])
    end

    it "ignores extra characters" do
      string = "D2 to E3"
      expect(parse(string)).to eql(["D2", "E3"])
    end
  end

  describe "#translate_from" do
    it "converts board locations to coordinates" do
      location = "D2"
      expect(translate_from(location)).to eql([3, 1])
    end
  end

  describe Board do
    before(:each) { @game = Board.new }

    describe "#piece" do
      it "returns a Piece object when a piece exists" do
        @game.board[0][0] = Queen.new(:B)
        piece = @game.board[0][0]
        expect(@game.piece(0, 0)).to equal(piece)
      end

      it "returns nil when a piece does not exist" do
        expect(@game.piece(0, 0)).to be nil
      end
    end

    describe "#move" do
      it "moves a piece" do
        @game.board[0][0] = Queen.new(:B)
        @game.move(0, 0, 0, 1)
        expect(@game.board[0][0]).to be nil
        expect(@game.board[0][1]).to be_an_instance_of(Queen)
      end
    end

  end

  describe Piece do
    before(:each) { @game = Board.new }

    describe "#poss_moves" do
      it "returns all possible moves without restriction" do
        pawn = Pawn.new(:W)
        expect(pawn.poss_moves(4, 1)).to eql([[4, 2], [4, 3]])
      end
    end
  end

end
