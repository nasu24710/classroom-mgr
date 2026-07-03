# frozen_string_literal: true

require_relative '../../lib/interactive_menu'

menu = InteractiveMenu.new

puts 'InteractiveMenu manual check'
puts

yes_no = menu.ask_yes_or_no('Proceed with the manual check?')
puts "ask_yes_or_no returned: #{yes_no.inspect}"
puts

selected = menu.select_from_list('Pick one option', ['Alpha', 'Beta', 'Gamma'])
puts "select_from_list returned: #{selected.inspect}"
