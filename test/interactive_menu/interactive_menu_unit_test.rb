require_relative '../test_helper'
require_relative '../../lib/interactive_menu'

class InteractiveMenuTest < Minitest::Test
  class FakePrompt
    attr_reader :yes_messages, :select_messages, :choices

    def initialize(yes_result: true, select_result: nil)
      @yes_result = yes_result
      @select_result = select_result
      @yes_messages = []
      @select_messages = []
      @choices = []
    end

    def yes?(message)
      @yes_messages << message
      @yes_result
    end

    def select(message)
      @select_messages << message

      menu = FakeMenu.new
      yield menu
      @choices = menu.choices

      return @select_result unless @select_result.nil?

      menu.choices.first&.last
    end
  end

  class FakeMenu
    attr_reader :choices

    def initialize
      @choices = []
    end

    def choice(label, value)
      @choices << [label, value]
    end
  end

  def with_prompt(prompt)
    original_new = TTY::Prompt.method(:new)
    TTY::Prompt.define_singleton_method(:new) { prompt }

    yield
  ensure
    TTY::Prompt.define_singleton_method(:new) do |*args, **kwargs, &block|
      original_new.call(*args, **kwargs, &block)
    end
  end

  def test_new
    prompt = FakePrompt.new
    menu = nil

    with_prompt(prompt) do
      menu = InteractiveMenu.new
    end

    assert_instance_of InteractiveMenu, menu
  end

  def test_ask_yes_or_no_returns_true_for_yes
    prompt = FakePrompt.new(yes_result: true)
    menu = nil

    with_prompt(prompt) do
      menu = InteractiveMenu.new
    end

    result = menu.ask_yes_or_no('Proceed?')

    assert_equal true, result
    assert_equal ['Proceed?'], prompt.yes_messages
  end

  def test_ask_yes_or_no_returns_false_for_no
    prompt = FakePrompt.new(yes_result: false)
    menu = nil

    with_prompt(prompt) do
      menu = InteractiveMenu.new
    end

    result = menu.ask_yes_or_no('Proceed?')

    assert_equal false, result
  end

  def test_ask_yes_or_no_invalid_message
    prompt = FakePrompt.new
    menu = nil

    with_prompt(prompt) do
      menu = InteractiveMenu.new
    end

    assert_raises(TypeError) do
      menu.ask_yes_or_no(123)
    end
  end

  def test_select_from_list_returns_selected_number
    prompt = FakePrompt.new(select_result: 1)
    menu = nil

    with_prompt(prompt) do
      menu = InteractiveMenu.new
    end

    result = menu.select_from_list('Choose one', ['Alpha', 'Beta', 'Gamma'])

    assert_equal 1, result
    assert_equal ['Choose one'], prompt.select_messages
    assert_equal [['Alpha', 0], ['Beta', 1], ['Gamma', 2]], prompt.choices
  end

  def test_select_from_list_returns_prompt_result
    prompt = FakePrompt.new(select_result: 2)
    menu = nil

    with_prompt(prompt) do
      menu = InteractiveMenu.new
    end

    result = menu.select_from_list('Choose one', ['Alpha', 'Beta', 'Gamma'])

    assert_equal 2, result
  end

  def test_select_from_list_invalid_arguments
    prompt = FakePrompt.new
    menu = nil

    with_prompt(prompt) do
      menu = InteractiveMenu.new
    end

    assert_raises(TypeError) do
      menu.select_from_list(123, ['Alpha'])
    end

    assert_raises(TypeError) do
      menu.select_from_list('Choose one', 'not an array')
    end

    assert_raises(TypeError) do
      menu.select_from_list('Choose one', [1, 2])
    end
  end

end
