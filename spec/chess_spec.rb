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

before(:each) { @game = Board.new }

  describe Board do

    describe "#set" do
      it "sets a piece on the board" do
        piece = @game.set(Queen.new(:B), 4, 4)
        expect(@game.board[4][4]).to equal(piece)
      end
    end

    describe "#get" do
      it "returns a Piece object when a piece exists" do
        @game.board[0][0] = Queen.new(:B)
        piece = @game.board[0][0]
        expect(@game.get(0, 0)).to equal(piece)
      end

      it "returns nil when a piece does not exist" do
        expect(@game.get(0, 0)).to be nil
      end
    end

    describe "#move" do
      it "moves a piece" do
        piece = Queen.new(:B)
        @game.set(piece, 0, 0)
        @game.move(0, 0, 0, 1)
        expect(@game.get(0, 0)).to be nil
        expect(@game.get(0, 1)).to equal(piece)
      end
    end

    describe "#valid_move?" do

      context "when checking for line of sight" do

        describe "#has_straight_los?" do
          before(:each) { @game.set(Pawn.new(:W), 4, 4) }

          it "clears horizontal move path, left to right" do
            expect(@game.has_straight_los?(0, 5, 7, 5)).to be true
            expect(@game.has_straight_los?(0, 4, 7, 4)).to be false
          end

          it "clears horizontal move path, right to left" do
            expect(@game.has_straight_los?(7, 5, 0, 5)).to be true
            expect(@game.has_straight_los?(7, 4, 0, 4)).to be false
          end

          it "clears vertical move path, top to bottom" do
            expect(@game.has_straight_los?(5, 7, 5, 0)).to be true
            expect(@game.has_straight_los?(4, 7, 4, 0)).to be false
          end

          it "clears vertical move path, bottom to top" do
            expect(@game.has_straight_los?(5, 0, 5, 7)).to be true
            expect(@game.has_straight_los?(4, 0, 4, 7)).to be false
          end
        end

        describe "#has_diag_los?" do
          before(:each) { @game.set(Queen.new(:B), 4, 4) }

          it "clears diagonal move path, bottom left to top right" do
            expect(@game.has_diag_los?(4, 4, 7, 7)).to be true
            expect(@game.has_diag_los?(0, 0, 7, 7)).to be false
          end

          it "clears diagonal move path, bottom right to top left" do
            expect(@game.has_diag_los?(4, 4, 1, 7)).to be true
            expect(@game.has_diag_los?(7, 1, 1, 7)).to be false
          end

          it "clears diagonal move path, top left to bottom right" do
            expect(@game.has_diag_los?(4, 4, 7, 1)).to be true
            expect(@game.has_diag_los?(1, 7, 7, 1)).to be false
          end

          it "clears diagonal move path, top right to bottom left" do
            expect(@game.has_diag_los?(4, 4, 0, 0)).to be true
            expect(@game.has_diag_los?(7, 7, 0, 0)).to be false
          end
        end

      end

      context "when pawns have special movement" do

        it "white pawns can attack diagonally upward" do
          @game.set(Queen.new(:B), 4, 4)
          @game.set(Pawn.new(:W), 3, 3)
          expect(@game.valid_move?(:W, 3, 3, 4, 4)).to be true
        end

        it "black pawns can attack diagonally downward" do
          @game.set(Queen.new(:W), 4, 4)
          @game.set(Pawn.new(:B), 5, 5)
          expect(@game.valid_move?(:B, 5, 5, 4, 4)).to be true
        end

        it "pawns can initially move 2 spaces" do
          @game.set(Pawn.new(:W), 4, 0)
          expect(@game.valid_move?(:W, 4, 0, 4, 2)).to be true
        end

        it "pawns cannot move 2 spaces if they have already moved" do
          @game.set(Pawn.new(:W), 4, 0)
          @game.move(4, 0, 4, 2)
          expect(@game.valid_move?(:W, 4, 2, 4, 4)).to be false
        end

      end

      it "returns false if no piece exists" do
        expect(@game.valid_move?(:B, 0, 0, 1, 1)).to be false
      end

      it "returns false if target is friendly" do
        @game.set(Pawn.new(:W), 4, 4)
        @game.set(Queen.new(:W), 4, 0)
        expect(@game.valid_move?(:W, 4, 0, 4, 4)).to be false
      end
    end

    describe "#scan_for_check" do
      before(:each) { @game.set(King.new(:W), 4, 0) }

      it "returns true when king is in check" do
        @game.set(Rook.new(:B), 4, 7)
        expect(@game.scan_for_check(:W)).to be true
      end

      it "returns false when king is not in check" do
        @game.set(Rook.new(:B), 3, 1)
        expect(@game.scan_for_check(:W)).to be false
      end

      it "returns false when piece is in the way" do
        @game.set(Rook.new(:B), 4, 7)
        @game.set(Pawn.new(:W), 4, 2)
        expect(@game.scan_for_check(:W)).to be false
      end
    end

    describe "#stalemate?" do
      before(:each) { @game.set(King.new(:W), 7, 7) }

      it "returns true when king is not in check but cannot move" do
        @game.set(Rook.new(:B), 6, 5)
        @game.set(King.new(:B), 7, 5)
        expect(@game.stalemate?(:W)).to be true
      end

      it "returns false when king is not in check and can move" do
        @game.set(Rook.new(:B), 6, 5)
        expect(@game.stalemate?(:W)).to be false
      end

      it "returns true when king is in check and cannot move" do
        @game.set(Rook.new(:B), 6, 5)
        @game.set(Queen.new(:B), 7, 5)
        expect(@game.stalemate?(:W)).to be true
      end

      it "returns false when king is in check but can move" do
        @game.set(Queen.new(:B), 7, 5)
        expect(@game.stalemate?(:W)).to be false
      end

      it "returns false when another piece can resolve it" do
        @game.set(Queen.new(:B), 7, 5)
        @game.set(Queen.new(:W), 5, 5)
        expect(@game.stalemate?(:W)).to be false
      end
    end
  end

  describe Piece do

    describe "#poss_moves" do
      it "returns possible moves without restriction" do
        pawn = Pawn.new(:W)
        expect(pawn.poss_moves(4, 1)).to eql([[4, 2], [4, 3]])
      end
    end
  end

end
