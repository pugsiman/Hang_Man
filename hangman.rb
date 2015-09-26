require 'yaml'

# main hangman class
class Game
  def initialize
    @selected_word = load_word
    @guesses = []
    @displayed_word = Array.new(@selected_word.length, '_ ')
    play
  end

  def new_game
    game_progress until !@displayed_word.include?('_ ') || @guesses.length == 10
    if !@displayed_word.include?('_ ')
      puts 'Nice job, you\'ve won.'
      end_game
    elsif @guesses.length == 10
      puts 'No wonder people think you\'re stupid, you\'ve lost.'
    end
  end

  private

  def play
    puts "\n      Welcome to hangman."
    puts '      Would you like to load an existing game, or start a new one?'
    puts '      Type load, new or exit'
    print "\n      "
    game_choice(gets.chomp.downcase)
  end

  def game_progress
    print "\n\n\n\n\n      #{@displayed_word.join} (#{@displayed_word.length})"
    print "#{visual_status}\n"
    display_guesses
    @guess = make_turn
    validate_letter
  end

  def load_word
    dictionary = File.readlines '5desk.txt'
    dictionary.select { |x| 4 < x.length && x.length < 13 }.sample.delete!("\n")
  end

  def game_choice(choice)
    case choice
    when 'new'  then new_game
    when 'load' then load_game
    when 'exit' then exit_game
    else
      puts '      You silly, you.'
      play
    end
  end

  def make_turn
    puts "\n      Choose a letter to guess, or type EXIT:"
    print "\n      "
    validate_input(gets.chomp.downcase)
  end

  def validate_input(input)
    if input == 'save'
      save_game
    elsif input == 'exit'
      exit_game
    elsif @guesses.include?(input)
      puts '      Already used that letter.'
      make_turn
    elsif (/[A-Za-z]/).match(input) && input.length == 1
      input
    else
      puts '      You can only enter a single letter.'
      make_turn
    end
  end

  def validate_letter
    if @selected_word.split('').include?(@guess)
      @selected_word.split('').each_with_index do |letter, idx|
        @displayed_word[idx] = "#{letter} " if @guess == letter
      end
    else
      @guesses << @guess unless @guess.nil?
    end
  end

  def display_guesses
    puts "\n      Incorrect guesses: [#{@guesses.join(', ')}]" unless @guesses.empty?
    puts "\n      You have #{10 - @guesses.size} tries left."
  end

  def end_game
    puts "\n      The word is #{@selected_word}"
  end

  def exit_game
    puts "      Wow, rude. Bye.\n"
    exit
  end

  # hangman visualization
  def visual_status
    next
  end

  # save and load methods
  def save_game
    Dir.mkdir('saves') unless Dir.exist? 'saves'
  end

  def load_game
    next
  end
end

Game.new
