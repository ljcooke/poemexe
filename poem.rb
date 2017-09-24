#!/usr/bin/env ruby
# -----------------------------------------------------------------------------
#
# .-----.-----.-----.--------.  .-----.--.--.-----.
# |  _  |  _  |  -__|        |__|  -__|_   _|  -__|
# |   __|_____|_____|__|__|__|__|_____|__.__|_____|
# |__|
#
# MIT License
# Copyright (c) 2014-2017 Liam Cooke
#
# Poems published on social media are licensed under the Creative Commons
# BY-NC-ND 4.0 license. Copyright (c) 2014-2017 Liam Cooke.
#
# https://poemexe.com
# https://github.com/ljcooke/poemexe
# https://twitter.com/poem_exe
# https://poemexe.tumblr.com
# https://botsin.space/@poem_exe
# https://oulipo.social/@quasihaiku
#
# -----------------------------------------------------------------------------

require 'date'
require 'json'
require 'optparse'


# -----------------------------------------------------------------------------
# poem.exe generates poems using an approach based on Leonard Richardson's
# Queneau Assembly technique. Each verse in the corpus is divided into three
# "buckets", consisting of one opening line, zero or more middle lines, and one
# closing line.
#
# The generator selects one of the patterns below, which determines the number
# of source poems and which bucket each line will be selected from. For the
# pattern [1, 2, 2, 3], a poem would be generated as follows:
#
#   1. Randomly select four poems from the corpus.
#   2. From the first poem, select the opening line (1).
#   3. From the second poem, randomly select a middle line (2), if any.
#   4. From the third poem, randomly select a middle line (2), if any.
#   5. From the fourth poem, select the closing line (3).
#   6. Put them all together, giving a poem 2-4 lines long.
# -----------------------------------------------------------------------------

HAIKU_FORM = { :pattern => [1, 2, 3], :keep_pauses => true }

ALT_FORMS = [
  { :pattern => [1, 3] },
  { :pattern => [1, 3, 1, 3] },
  { :pattern => [1, 2, 2, 3] },
]

# -----------------------------------------------------------------------------
# Poems may be accepted or rejected if they contain any seasonal reference
# keywords. These are mostly based on the Japanese kigo (words or phrases
# associated with particular seasons in Japan).
#
# As poem.exe has readers in both hemispheres, the "seasons" have been
# simplified to two: summer-winter and autumn-spring.
#
# Seasonal references are categorised as either STRONG or WEAK. STRONG
# references are mutually exclusive; WEAK references may overlap. A poem may be
# accepted or rejected based on any STRONG references it contains; if there are
# none, the poem will be accepted if it contains a relevant WEAK reference.
#
# For example, "winter" is a STRONG reference. A poem containing the word
# "winter" would be rejected in autumn-spring; in summer-winter it would be
# accepted unless the poem also contained a STRONG reference to autumn-spring.
# -----------------------------------------------------------------------------

SEASON_STRONG_MATCH = [
  /summer|winte?r|solsti[ct]/,
  /autumn|spring|equino[xc]/,
]

MONTH_STRONG_MATCH = [
  /\b(january)/,
  /\b(february|valentine)/,
  /\b(in\smarch|shamrock)/,
  /\b(april)/,
  /\b(in\smay)/,
  /\b(june)/,
  /\b(july)/,
  /\b(august)/,
  /\b(september)/,
  /\b(october|hallowe.?en|trick.or.treat)/,
  /\b(november)/,
  /\b(december|christmas|end.of.(the.)?year|presents|santa|sleigh)/,
]

SEASON_WEAK_MATCH = [
  # summer-winter
  %r{
    \b(bath|beach|bicycle|bike|cicada|cycl|cuckoo|field|
       heat|hot|ice.?cream|iris|jellyfish|lilac|lotus|
       meadow|mosquito|naked|nap|nud[ei]|orange|rain|
       siesta|smog|snake|sun|surf|sweat|swim|waterfall|
       grasshopper|fireworks|kimono)
    |
    \b(chill|cold|fallen.*lea[fv]|freez|frost|ic[eyi]|
       night|oyster|smog|snow|white)
  }x,

  # autumn-spring
  %r{
    \b(age|apple|brown|death|die|evergreen|
       fall\b|grape|gr[ea]y|harvest|insect|iris|
       lea[fv]|melanchol|mellow|moon|night|old|peach|
       pear|persimmon|ripe|scarecrow|school|sorrow|
       thunder|typhoon|dragonfl[yi])
    |
    \b(cherry.blossom|flower|frog|haz[ey]|heather|
       lark|lilac|mist|nightingale|peach|popp[yi]|
       sunflower|sweet|warbler|warm|wildflower|
       breeze|stream|butterfl[yi])
  }x,
]

MONTH_WEAK_MATCH = [
  /\b(first)/,
  /\b(cupid|heart|love)/,
  /\b(equino[xc])/,
  nil,
  nil,
  /\b(solsti[ct])/,
  nil,
  nil,
  /\b(equino[xc])/,
  /\b(afraid|bone|cemetery|cobweb|fog|fright|ghost|grave|grim|hallowe|haunt|headstone|
      pumpkin|scare|scream|skelet|skull|spider|spine|spook|tomb|witch|wizard)/x,
  nil,
  /\b(bells|carol|festive|gift|jingl|joll|joy|merry|solsti[ct]|tree|twinkl)/,
]

# -----------------------------------------------------------------------------
# With the bulk of the corpus consisting of haiku by Kobayashi Issa, poem.exe
# quickly developed its own particular fondness for snails (an early classic:
# "snail / between my hands / snail"). Here we give the word a little extra
# weight, for the fans.
# -----------------------------------------------------------------------------

ALWAYS_IN_SEASON = /snail/


module PoemExe
  def self.format_poem(text, opts={})
    poem = text.strip.downcase.gsub(/\.{2,}/, "\u2026").gsub(/[.]$/, ';')
    # move some words to the preceding line
#    unless rand > 0.5
#      poem.gsub! /(\w|,|;)\n(among|in|of|on|that|towards?)\s/, "\\1 \\2\n"
#      poem.gsub! /(,|;)\n(i|is)\s/, "\\1 \\2\n"
#    end
    # strip punctuation
    poem.gsub! /[;]$/, ''
    poem.gsub! /[;]/, ','
    poem.gsub! /[.,:;\u2014]$/, ''
    poem = poem.split("\n").join(' / ') if opts[:single_line]
    poem
  end

  class Queneau
    def initialize(corpus_filename)
      @tweets = JSON.parse(File.read(corpus_filename), symbolize_names: true)
    end

    def sample
      lines = []
      form = (rand(5) > 0) ? HAIKU_FORM : ALT_FORMS.sample
      tweets = @tweets.sample(form[:pattern].length)
      form[:pattern].each_with_index do |bucket_num, tweet_index|
        bucket = case bucket_num
                 when 1 then :a
                 when 2 then :b
                 when 3 then :c
                 else nil
                 end
        next if bucket.nil?
        line = tweets[tweet_index][bucket].sample
        unless line.nil?
          line = line.gsub(/\u2014|\u2026/, ' ').split.join(' ') unless form[:keep_pauses]
          lines << line
        end
      end
      lines
    end
  end

  class Poet
    def initialize(model_name, options={})
      @model_name = model_name
      @mtime = {}
      @queneau = nil
      @vocab = nil
      @excludes = []

      load_model :force => true

      @oulipo = options[:oulipo] || false
    end

    def load_model(opts={})
      updated = false

      corpus_filename = "corpus/#{@model_name}.json"
      mtime = File.mtime(corpus_filename)
      if opts[:force] or mtime != @mtime[:corpus]
        @queneau = PoemExe::Queneau.new corpus_filename
        @mtime[:corpus] = mtime
        updated = true
      end

      vocab_filename = "corpus/vocab.json"
      mtime = File.mtime(vocab_filename)
      if opts[:force] or mtime != @mtime[:vocab]
        @vocab = JSON.parse(File.read(vocab_filename), symbolize_names: true)
        @mtime[:vocab] = mtime
        updated = true
      end

      path = 'excludes.txt'
      mtime = File.mtime(path)
      if opts[:force] or mtime != @mtime[:excludes]
        @excludes = File.open(path).map { |line|
          pattern = line.split('#', 2).first.strip
          Regexp.new(pattern, Regexp::IGNORECASE) unless pattern.empty?
        }.compact
        @mtime[:excludes] = mtime
        updated = true
      end

      updated
    end

    def excluded?(poem)
      @excludes.any? { |pattern| pattern.match(poem) }
    end

    def timely?(poem, month)
      text = poem.downcase
      strong = ALWAYS_IN_SEASON.match(text)

      # check some tricky STRONG references
      if /\b(new.?year|first.day.*year)/.match(text)
        return false unless [1, 12].include? month
        strong = true
      elsif /\b(thanksgiving|giv.*thanks)/.match(text)
        return false unless [10, 11].include? month
        strong = true
      end

      # check for STRONG month references
      MONTH_STRONG_MATCH.each_with_index do |pattern, i|
        if pattern && pattern.match(text)
          return false if i != month - 1
          strong = true
        end
      end

      # check for STRONG seasonal references
      season = ((month + 1) / 3) % 2
      SEASON_STRONG_MATCH.each_with_index do |pattern, i|
        if pattern && pattern.match(text)
          return false if i != season
          strong = true
        end
      end

      # all negative tests passed; return if there was a STRONG reference
      return true if strong

      # check for WEAK month references
      pattern = MONTH_WEAK_MATCH[month - 1]
      return true if !pattern.nil? && pattern.match(text)

      # check for WEAK seasonal references
      pattern = SEASON_WEAK_MATCH[season]
      return true if !pattern.nil? && pattern.match(text)

      # no references at all; small chance to keep it
      rand(6) == 0
    end

    def substitute_vocab(poem)
      return poem unless poem.include? '%'

      # Match strings of the form %key.index%, e.g. %noun.1%
      pattern = /%(?<key>[^.%]+)(\.(?<index>[0-9]+))?%/

      updated = poem.gsub(pattern) do
        match = Regexp.last_match
        key = match[:key].to_sym
        index = [match[:index].to_i - 1, 0].max
        vocab = @vocab[key].sample()[index]
        return nil unless vocab
        vocab
      end

      return nil if updated.include? '%'
      updated
    end

    def make_poem(opts={})
      month = opts[:month] || Time.now.month
      poem = ''
      1000.times do |i|

        lines = []
        10.times do
          lines = @queneau.sample.select { |line| line and not line.empty? }
          break if lines and lines.length > 1
        end

        lines = lines.map { |line|
          line.gsub(/\{.*?\}/) { |choices| choices[1...-1].split(',').sample }
        }

        if lines and lines.any?

          # repeat the first line sometimes
          if lines.count > 2 and rand <= 0.05
            if lines.count == 3 and rand <= 0.3
              lines.insert 2, lines[0]
            else
              lines << lines[0]
            end
          end

          lines.map! { |line| line.strip }
          poem = PoemExe.format_poem(lines.join("\n"), opts)
          poem = substitute_vocab(poem) #rescue nil
          next if poem.nil?
          next if @oulipo and poem.match /e/i
          next if excluded? poem
          return poem if timely?(poem, month)
        end

      end
      return nil
    end
  end
end

# -----------------------------------------------------------------------------
# Command-line usage example:
#
#     ./poem.rb -n3
#         Generate three poems.
# -----------------------------------------------------------------------------

def main
  num_poems = 1
  month = nil
  options = {}

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: poem.rb [-n NUM]"
    opts.on('-m=MONTH', 'override the current month') do |m|
      m = m.to_i
      month = m if m >= 1 && m <= 12
    end
    opts.on('-n=NUM', 'number of poems to generate') do |n|
      num_poems = [n.to_i, 1].max
    end
    opts.on('-O', '--oulipo', 'ignore the letter e') do
      options[:oulipo] = true
    end
  end
  parser.parse!

  puts "== #{Date::MONTHNAMES[month]} ==\n" unless month.nil?

  poem_exe = PoemExe::Poet.new 'haiku', options
  poems = num_poems.times.map do
    poem_exe.make_poem(:month => month)
  end
  puts poems.join "\n\n"
end

main if $PROGRAM_NAME == __FILE__
