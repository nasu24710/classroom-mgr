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

  def select_from_list(message, options)
    unless message.is_a?(String)
      raise TypeError, 'message must be a String.'
    end

    unless options.is_a?(Array) && options.all? { |option| option.is_a?(String) } && !options.empty?
      raise TypeError, 'options must be an Array of Strings.'
    end

    @prompt.select(message, show_help: :never) do |menu|
      options.each_with_index do |option, index|
        menu.choice(option, index)
      end
    end
  end
end
