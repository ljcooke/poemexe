# frozen_string_literal: true

module PoemExe
  # Command-line usage example:
  #
  #     bundle exec ruby lib/poem_exe.rb -n 3
  #         Generate three poems.

  module CLI
    DEFAULT_CONFIG = {
      month: nil,
      num_poems: 1,
      single_line: false,
      options: {},
    }.freeze

    def self.parse_args
      DEFAULT_CONFIG.dup.tap do |config|
        OptionParser.new do |opts|
          opts.banner = "Usage: poem.rb [-n NUM]"

          opts.on('-m=MONTH', 'override the current month') do |m|
            month = m.to_i
            config[:month] = month if (1..12).cover?(month)
          end

          opts.on('-n=NUM', 'number of poems to generate') do |n|
            config[:num_poems] = [1, n.to_i].max
          end

          opts.on('-O', '--oulipo', 'ignore the letter e') do
            config[:options][:oulipo] = true
          end

          opts.on('-L=CHARS', '--max-length=CHARS', 'maximum length') do |n|
            config[:options][:max_length] = n.to_i
          end

          opts.on('-1', '--single-line', 'format the poem on one line') do
            config[:single_line] = true
          end
        end.parse!
      end
    end

    def self.main
      config = parse_args
      month = config[:month]

      puts "== #{Date::MONTHNAMES[month]} ==\n" unless month.nil?

      poem_exe = PoemExe::Poet.new(config[:options])
      poems = Array.new(config[:num_poems]) do
        poem_exe.generate month: month,
                          single_line: config[:single_line]
      end

      puts poems.join "\n\n"
    end
  end
end
