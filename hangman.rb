require 'yaml'

# Main hangman class
class Game
  def initialize
    @selected_word = load_word
    @guesses = []
    @displayed_word = Array.new(@selected_word.length, '_ ')
    play
  end

  def play
    puts "\n      Welcome to hangman."
    puts '      Would you like to load an existing game, or start a new one?'
    print '      Type load, new or exit: '
    game_choice(gets.chomp.downcase)
  end

  def new_game
    puts "\e[H\e[2J"
    game_progress until !@displayed_word.include?('_ ') || @guesses.length == 10
    if @guesses.length == 10
      puts "\n      No wonder people think you\'re silly, you\'ve lost."
      puts "\n      The word was #{@selected_word}."
    else
      puts "\n      Nice job, you\'ve won."
      puts "\n      The word was indeed #{@selected_word}."
    end
  end

  private

  def game_progress
    print "\n\n\n\n\n      #{@displayed_word.join} (#{@displayed_word.length})"
    print "#{visual_status}\n"
    display_guesses
    @guess = make_turn
    validate_letter
  end

  def load_word
    dictionary = File.readlines '5desk.txt'
    # a random word from an array of 5 to 12 characters-long words.
    dictionary.select { |x| x.length.between?(5, 13) }.sample.delete!("\n")
  end

  def game_choice(choice)
    case choice
    when 'new'  then new_game
    when 'load' then load_game
    when 'exit' then puts '      Wow, rude. Bye.'
    else
      puts '      You silly goose, you. Try again.'
      play
    end
  end

  def make_turn
    print "\n      Choose a letter to guess, or type EXIT: "
    validate_input(gets.chomp.downcase)
  end

  def validate_input(input)
    if @guesses.include?(input)
      puts '      Already used that letter, monkey.'
      make_turn
    elsif (/[A-Za-z]/).match(input) && input.length == 1
      input
    elsif input == 'save'
      save_game
    elsif input == 'exit'
      puts "      Wow, rude. Bye."
      exit
    else
      puts '      You can only enter a letter, and a single one at that.'
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

  # Hangman visualization
  def visual_status; end

  # Save and load methods
  def save_game
    Dir.mkdir('saves') unless Dir.exist? 'saves'
    File.open('saves/save.yaml', 'w') do |file|
      file << YAML.dump(self)
    end
    puts '      Game has been saved'
    exit
  end

  def load_game
    if File.exist?('saves/save.yaml')
      data = File.open('saves/save.yaml', &:read) # May not work for older versions of ruby
      YAML.load(data).new_game
    else
      puts 'You have no save file. Are you feeling alright?'
    end
  end
end

Game.new
