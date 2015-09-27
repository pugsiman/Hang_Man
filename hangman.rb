require 'yaml'

# Adding method to Array that removes spaces inside scope of the string.
class Array
  def unspace
    join.gsub(/[[:space:]]/, '')
  end
end

# Hangman game class
class Game
  def initialize
    @selected_word = load_word
    @guesses = []
    @displayed_word = Array.new(@selected_word.length, '_ ')
    start_screen
  end

  protected

  def start_screen
    puts "\n      Welcome to hangman."
    puts '      Would you like to load an existing game, or start a new one?'
    print '      Type load, new or exit: '
    game_choice(gets.chomp.downcase)
  end

  def new_game
    puts "\e[H\e[2J" # using the clear command through ASCII.
    progress until win_game
    if @guesses.size == 10
      puts "\n      No wonder people think you\'re silly, you\'ve lost."
      puts "\n      The word was '#{@selected_word}'."
    else
      puts "\n      Nice job, you\'ve won."
      puts "\n      The word was indeed '#{@selected_word}'."
    end
  end

  private

  def game_choice(choice)
    case choice
    when 'new'  then new_game
    when 'load' then load_game
    when 'exit' then puts '      Wow, rude. Bye.'
    else
      puts '      You silly goose, you. Try again.'
      start_screen
    end
  end

  def progress
    print "\n\n\n\n\n      #{@displayed_word.join} (#{@displayed_word.length})"
    visual_status
    puts "\n      Incorrect guesses: [#{@guesses.join(', ')}]" unless @guesses.empty?
    puts "\n      You have #{10 - @guesses.size} tries left."
    print "\n      Choose a letter to guess, save, or type EXIT: "
    @guess = validate_input(gets.chomp.downcase)
    check_guess
  end

  def load_word
    dictionary = File.readlines '5desk.txt'
    # A random word from an array of 5 to 12 characters-long words.
    normal_range = proc { |x| x.length.between?(5, 12) }
    dictionary.select(&normal_range).sample.downcase.delete!("\n")
  end

  def validate_input(input)
    if @guesses.include?(input)
      puts "\n      Already used that letter, monkey."
      revalidate
    elsif (/[a-z]/).match(input) && input.length == 1
      input
    elsif input == 'save'
      save_game
    elsif input == 'exit'
      puts "\n      Wow, rude. Bye."
      exit
    else
      puts "\n      You can only enter a letter, and a single one at that."
      revalidate
    end
  end

  # Fail-safe (re)method to avoid recursively applying Array methods.
  def revalidate
    validate_input(gets.chomp.downcase)
  end

  # Display the letter if the selected word containts it.
  def check_guess
    if @selected_word.split('').include?(@guess)
      @selected_word.split('').each_with_index do |letter, idx|
        @displayed_word[idx] = "#{letter} " if @guess == letter
      end
    else
      @guesses << @guess unless @guess.nil?
    end
  end

  # Check for win sequence.
  def win_game
    @displayed_word.unspace == @selected_word || @guesses.size == 10
  end

  # Hangman current state visualizatin with lame ASCII art.
  def visual_status
    visuals = [
      %(),
      %(
        ____
      ),
      %(
          |
          |
          |
          |
        __|__
      ),
      %(
          ______
          |
          |
          |
          |
        __|__
      ),
      %(
          ______
          |     |
          |
          |
          |
        __|__
      ),
      %(
          ______
          |     |
          |     O
          |
          |
        __|__
      ),
      %(
          ______
          |     |
          |     O
          |     |
          |
        __|__
      ),
      %(
          ______
          |     |
          |     O
          |     |
          |    /
        __|__
      ),
      %(
          ______
          |     |
          |     0
          |     |
          |    / \
        __|__
      ),
      %(
          ______
          |     |
          |    \0
          |     |
          |    / \
        __|__
      ),
      %(
          ______
          |     |
          |    \0/
          |     |
          |    / \
        __|__)
    ]
    puts "\n\n\n\n\n", visuals[@guesses.size]
  end

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
      # May not work for older versions of ruby
      data = File.open('saves/save.yaml', &:read)
      YAML.load(data).new_game
    else
      puts 'You have no save file. Are you feeling alright?'
      start_screen
    end
  end
end

Game.new
