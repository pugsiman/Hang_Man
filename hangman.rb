require 'yaml'

# Removes spaces inside the scope of the string.
class Array
  def unspace
    join.gsub(/\s+/, '')
  end
end

# Aligning strings to the right.
class String
  def pad
    rjust(length + 6)
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
    puts 'Would you like to load an existing game, or start a new one?'.pad
    print 'Type load, new or exit: '.pad
    game_choice(gets.chomp.downcase)
  end

  def new_game
    progress until finish_game
    if @guesses.size == 10
      puts "\e[H\e[2J" # ANSI clear
      puts "\n      No wonder people think you\'re silly, you\'ve lost."
      puts "\n      The word was '#{@selected_word}'."
      visual_status
    else
      puts "\e[H\e[2J" # ANSI clear
      puts "\n      Nice job, you\'ve won."
      puts "\n      The word was indeed '#{@selected_word}'."
    end
  end

  private

  def game_choice(choice)
    case choice
    when 'new'  then new_game
    when 'load' then load_game
    when 'exit' then puts 'Wow, rude. Bye.'.pad
    else
      puts 'You silly goose, you. Try again.'.pad
      start_screen
    end
  end

  def progress
    puts "\e[H\e[2J" # ANSI clear
    print "\n\n\n\n\n      #{@displayed_word.join} (#{@displayed_word.length})"
    visual_status
    puts "\n      Incorrect guesses: [#{@guesses.join(', ')}]" unless @guesses.empty?
    puts "\n      You have #{10 - @guesses.size} tries left.\n"
    print 'Choose a letter to guess, save, or type EXIT: '.pad
    @guess = validate_input(gets.chomp.downcase)
    check_guess
  end

  def load_word
    dictionary = File.readlines '5desk.txt'
    # A random word from an array of 5 to 12 characters-long words.
    normal_range = proc { |x| x.length.between?(5, 12) }
    dictionary.select(&normal_range).sample.downcase.chop # remove \n leftover
  end

  def validate_input(input)
    if @guesses.include?(input)
      puts
      puts 'Already used that letter, monkey.'.pad
      revalidate
    elsif (/[a-z]/).match(input) && input.length == 1
      input
    elsif input == 'save'
      save_game
    elsif input == 'exit'
      puts
      puts 'Wow, rude. Bye.'.pad
      exit
    else
      puts
      puts 'You can only enter a letter, and a single one at that.'.pad
      revalidate
    end
  end

  # Fail-safe (re)method to avoid recursively applying Array methods.
  def revalidate
    print ''.pad
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
  def finish_game
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
      %q(
          ______
          |     |
          |     O
          |     |
          |    / \
        __|__
      ),
      %q(
          ______
          |     |
          |    \O
          |     |
          |    / \
        __|__
      ),
      %q(
          ______
          |     |
          |    \O/
          |     |
          |    / \
        __|__
      )
    ]
    puts "\n\n\n\n\n", visuals[@guesses.size]
  end

  # Save and load methods
  def save_game
    Dir.mkdir('saves') unless Dir.exist? 'saves'
    File.open('saves/save.yaml', 'w') do |file|
      file << YAML.dump(self)
    end
    puts 'Game has been saved.'.pad
    exit
  end

  def load_game
    if File.exist?('saves/save.yaml')
      # May not work for older versions of ruby
      data = File.open('saves/save.yaml', &:read)
      YAML.load(data).new_game
    else
      puts 'You have no save file. Are you feeling alright?'.pad
      start_screen
    end
  end
end

Game.new
