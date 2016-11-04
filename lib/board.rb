require "yaml"

module Chess
  COLS = %w{ A B C D E F G H }
  ROWS = (1..8).to_a.reverse
  SAVE_FILE = "./game.sav"

  class Board
    attr_reader :board

    def initialize
      @turn = 0
      @game_over = false
      @board = Array.new(8) { Array.new(8) }
    end

    def play
      set_board
      tutorial
      until @game_over
        turn
      end
    end

    def set_board
      0.upto(7) do |col|
        set(Pawn.new(:W), col, 1)
        set(Pawn.new(:B), col, 6)
      end
      [0, 7].each do |col|
        set(Rook.new(:W), col, 0)
        set(Rook.new(:B), col, 7)
      end
      [1, 6].each do |col|
        set(Knight.new(:W), col, 0)
        set(Knight.new(:B), col, 7)
      end
      [2, 5].each do |col|
        set(Bishop.new(:W), col, 0)
        set(Bishop.new(:B), col, 7)
      end
      set(King.new(:W), 4, 0)
      set(King.new(:B), 4, 7)
      set(Queen.new(:W), 3, 0)
      set(Queen.new(:B), 3, 7)
    end

    def tutorial
      puts
      puts "   Welcome to Chess!"
      puts "   Move by entering board locations."
      puts "   For example, move a pawn by entering: D2 D4"
      puts "   Checkmate your opponent to win."
      puts
      puts "   To save or load a game, type 'save' or 'load' at any turn."
      puts "   Exit the game by typing 'exit'."
      puts "   To repeat these instructions, type 'help'."
      puts
    end

    def turn
      draw
      loop do
        begin
        curr_team = @turn % 2 == 0 ? :W : :B
        break if mated?(curr_team)
        print (curr_team == :W ? "   [WHITE " : "   [BLACK ")
        print "Move"
        print " -CHECK- " if scan_for_check(curr_team)
        print "]: "
        input = gets.chomp.upcase
        abort if ["EXIT", "QUIT"].include?(input)
        if input.include?("SAVE")
          save_game
          next
        elsif input.include?("LOAD")
          load_game
          next
        elsif input.include?("HELP")
          tutorial
          next
        end
        move_attempt = parse(input)
        from_coords = translate_from(move_attempt[0])
        to_coords = translate_from(move_attempt[1])
        if valid_move?(curr_team, from_coords[0], from_coords[1], to_coords[0], to_coords[1])
          copy = get(to_coords[0], to_coords[1])
          test_move(from_coords[0], from_coords[1], to_coords[0], to_coords[1])
          if scan_for_check(curr_team)
            revert_test(from_coords[0], from_coords[1], to_coords[0], to_coords[1])
            set(copy, to_coords[0], to_coords[1])
            puts "   You cannot move there, your king will be in check."
          else
            revert_test(from_coords[0], from_coords[1], to_coords[0], to_coords[1])
            set(copy, to_coords[0], to_coords[1])
            move(from_coords[0], from_coords[1], to_coords[0], to_coords[1])
            break
          end
        else
          puts "   Invalid move, try again."
        end
        rescue
          puts "   Invalid move, try again."
        end
      end
      @turn += 1
    end

    def set(piece, col, row)
      @board[col][row] = piece
    end

    def get(col, row)
      return nil if @board[col].nil?
      return @board[col][row] if @board[col][row].is_a?(Piece)
      nil
    end

    def delete(col, row)
      return nil if @board[col].nil?
      @board[col][row] = nil
    end

    def save_game
      if File.exists?(SAVE_FILE)
        loop do
          print "   This will overwrite your previous save. Overwrite? "
          choice = gets.chomp.downcase
          if choice.start_with?("n")
            puts
            puts "   [Save cancelled]"
            puts
            return
          elsif choice.start_with?("y")
            break
          else
            puts "   Invalid choice. Enter [y/n]"
          end
        end
      end
      data = {
      :turn => @turn,
      :game_over => @game_over,
      :board => @board   
      }
      File.open(SAVE_FILE, "w") { |file| YAML.dump(data, file) }
      puts
      puts "   [Game saved]"
      puts
    end

    def load_game
      if File.exists?(SAVE_FILE)
        data = YAML.load_file(SAVE_FILE)
        @turn = data[:turn]
        @game_over = data[:game_over]
        @board = data[:board]
        draw
        puts
        puts "   [Game loaded]"
        puts
      else
        puts
        puts "   [No save file exists]"
        puts
      end
    end

    def test_move(from_col, from_row, to_col, to_row)
      copy = get(from_col, from_row)
      set(copy, to_col, to_row)
      delete(from_col, from_row)
    end

    def revert_test(from_col, from_row, to_col, to_row)
      copy = get(to_col, to_row)
      set(copy, from_col, from_row)
      delete(to_col, to_row)
    end

    def mated?(curr_team)
      if stalemate?(curr_team)
        @game_over = true
        if scan_for_check(curr_team)
          victor = curr_team == :W ? "[BLACK]" : "[WHITE]"
          puts "   Checkmate! #{victor} wins!"
          puts
          return true
        else
          puts "   The game has ended in a stalemate."
          puts
          return true
        end
      end
      false
    end

    def stalemate?(curr_team)
      0.upto(7) do |from_col|
        0.upto(7) do |from_row|
          piece = get(from_col, from_row)
          if piece.is_a?(Piece) && piece.team == curr_team
            0.upto(7) do |to_col|
              0.upto(7) do |to_row|
                if valid_move?(curr_team, from_col, from_row, to_col, to_row)
                  stalemate = false
                  copy = get(to_col, to_row)
                  test_move(from_col, from_row, to_col, to_row)
                  stalemate = true if scan_for_check(curr_team)
                  revert_test(from_col, from_row, to_col, to_row)
                  set(copy, to_col, to_row)
                  return false unless stalemate
                end
              end
            end
          end
        end
      end
      true
    end

    def scan_for_check(curr_team)
      enemy = curr_team == :W ? :B : :W
      enemy_moves = []
      king_loc = []
      0.upto(7) do |from_col|
        0.upto(7) do |from_row|
          piece = get(from_col, from_row)
          unless piece.nil?
            if piece.team == enemy
              0.upto(7) do |to_col|
                0.upto(7) do |to_row|
                  if valid_move?(enemy, from_col, from_row, to_col, to_row)
                    enemy_moves << [to_col, to_row] unless enemy_moves.include?([to_col, to_row])
                  end
                end
              end
            end
            if piece.is_a?(King) && piece.team == curr_team
              king_loc = [from_col, from_row]
            end
          end
        end
      end
      return true if enemy_moves.include?(king_loc)
      false
    end

    def valid_move?(curr_team, from_col, from_row, to_col, to_row)
      curr_piece = get(from_col, from_row)
      return false if curr_piece.nil?
      return false unless curr_team == curr_piece.team
      if get(to_col, to_row)
        return false if curr_piece.team == get(to_col, to_row).team
      end
      if curr_piece.is_a?(Pawn)
        if (from_col == to_col)
          return false if get(to_col, to_row)
          return false unless has_straight_los?(from_col, from_row, to_col, to_row)
        elsif (to_col - from_col).abs == 1
          if curr_team == :W && (to_row - from_row == 1)
            return true if get(to_col, to_row)
          elsif curr_team == :B && (from_row - to_row == 1)
            return true if get(to_col, to_row)
          end
        end
      end
      return false unless curr_piece.poss_moves(from_col, from_row).include?([to_col, to_row])
      if curr_piece.is_a?(Rook)
        return false unless has_straight_los?(from_col, from_row, to_col, to_row)
      elsif curr_piece.is_a?(Bishop)
        return false unless has_diag_los?(from_col, from_row, to_col, to_row)
      elsif curr_piece.is_a?(Queen)
        if (from_col == to_col) || (from_row == to_row)
          return false unless has_straight_los?(from_col, from_row, to_col, to_row)
        else
          return false unless has_diag_los?(from_col, from_row, to_col, to_row)
        end
      end
      true
    end

    def has_straight_los?(from_col, from_row, to_col, to_row)                 
      if from_col == to_col
        from_row, to_row = to_row, from_row if from_row > to_row
        for row in from_row + 1...to_row
          return false unless get(from_col, row).nil?
        end
      else
        from_col, to_col = to_col, from_col if from_col > to_col
        for col in from_col + 1...to_col
          return false unless get(col, from_row).nil?
        end
      end
      true
    end

    def has_diag_los?(from_col, from_row, to_col, to_row)
      if (from_col > to_col) && (from_row > to_row)
        from_col, to_col = to_col, from_col
        from_row, to_row = to_row, from_row
      end
      if (from_col < to_col) && (from_row < to_row)
        col = from_col + 1
        row = from_row + 1
        until col == to_col && row == to_row
          return false unless get(col, row).nil?
          col += 1
          row += 1
        end
      else
        if (from_col > to_col) && (from_row < to_row)
          from_col, to_col = to_col, from_col
          from_row, to_row = to_row, from_row
        end
        col = from_col + 1
        row = from_row - 1
        until col == to_col && row == to_row
          return false unless get(col, row).nil?
          col += 1
          row -= 1
        end
      end
      true
    end

    def move(from_col, from_row, to_col, to_row)
      piece = get(from_col, from_row)
      set(piece, to_col, to_row)
      if piece.is_a?(Pawn)
        piece.moved = true
        if piece.team == :W && to_row == 7
          promote(to_col, to_row)
        elsif piece.team == :B && to_row == 0
          promote(to_col, to_row)
        end
      elsif (piece.class == Rook || piece.class == King)
        piece.moved = true
      end
      delete(from_col, from_row)
    end

    def promote(col, row)
      team = get(col, row).team
      puts "   A pawn has been promoted!"
      loop do
        puts "   Select one [BISHOP] [KNIGHT] [ROOK] [QUEEN]: "
        choice = gets.chomp.upcase
        if choice.start_with?("Q")
          @board[col][row] = Queen.new(team)
          break
        elsif choice.start_with?("K")
          @board[col][row] = Knight.new(team)
          break
        elsif choice.start_with?("B")
          @board[col][row] = Bishop.new(team)
          break
        elsif choice.start_with?("R")
          @board[col][row] = Rook.new(team)
          break
        else
          puts "   Invalid choice, try again."
        end
      end
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
      return get(col, row).icon if get(col, row)
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

  def parse(input)
    from = nil
    to = nil
    if match = input.match(/(^\w\d).*(\w\d$)/i)
      from, to = match.captures
    end
    return nil if from.nil?
    [from, to]
  end

  def translate_from(location)
    coords = []
    COLS.each_with_index do |col, index|
      coords << index if col == location[0]
    end
    coords << location[1].to_i - 1
    coords
  end

end
