require 'date'
require_relative 'poem'

options = {}
options[:oulipo] = true if ARGV.include? '--oulipo'

p = PoemExe::Poet.new('haiku', options)

(1..12).each do |month|
  1.times do
    poem = p.make_poem(single_line: true, month: month)
    prefix = sprintf('%02d', month)
    puts "#{prefix}  #{poem}"
  end
end
