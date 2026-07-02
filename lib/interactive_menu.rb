require 'tty-prompt'

class InteractiveMenu
  def initialize
    @prompt = TTY::Prompt.new(symbols: { marker: '→' }, enable_color: false)
  end

  def ask_yes_or_no(message)
    unless message.is_a?(String)
      raise TypeError, 'message must be a String.'
    end

    @prompt.select(message, show_help: :never) do |menu|
      menu.choice('yes', true)
      menu.choice('no', false)
    end
  end

  def select_from_list(message, options, header: nil)
    unless message.is_a?(String)
      raise TypeError, 'message must be a String.'
    end

    unless options.is_a?(Array) && options.all? { |option| option.is_a?(String) } && !options.empty?
      raise TypeError, 'options must be an Array of Strings.'
    end

    unless header.nil? || header.is_a?(String)
      raise TypeError, 'header must be a String.'
    end

    selected_index = @prompt.select(message, show_help: :never, quiet: true) do |menu|
      options.each_with_index do |option, index|
        menu.choice(option, index)
      end
    end

    puts message
    puts "  #{header}" unless header.nil?
    options.each_with_index do |option, index|
      marker = index == selected_index ? '→' : ' '
      puts "#{marker} #{option}"
    end
    puts

    selected_index
  end
end
