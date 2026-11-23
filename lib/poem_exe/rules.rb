# frozen_string_literal: true

module PoemExe
  class Rule
    def initialize(pattern)
      @pattern = pattern
    end

    def match_text?(text)
      @pattern.match?(text)
    end
  end

  class MonthRule < Rule
    def initialize(months, pattern)
      super(pattern)
      @months = months
    end

    def match_month?(month)
      @months.include?(month)
    end
  end

  # ---------------------------------------------------------------------------
  # Poems may be accepted or rejected if they contain any seasonal reference
  # keywords. These are mostly based on the Japanese kigo (words or phrases
  # associated with particular seasons in Japan).
  #
  # As poem.exe has readers in both hemispheres, the "seasons" have been
  # simplified to two: Summer/Winter and Autumn/Spring.
  #
  # Seasonal references are categorised as either STRONG or WEAK. STRONG
  # references are mutually exclusive; WEAK references may overlap. A poem may
  # be accepted or rejected based on any STRONG references it contains; if
  # there are none, the poem will be accepted if it contains a relevant WEAK
  # reference.
  #
  # For example, "winter" is a STRONG reference. A poem containing the word
  # "winter" would be rejected in Autumn/Spring; in Summer/Winter it would be
  # accepted unless the poem also contained a STRONG reference to
  # Autumn/Spring.
  # ---------------------------------------------------------------------------

  # "The plural of regex is regrets"
  # https://twitter.com/ifosteve/status/1190348262500421634

  STRONG_RULES = [
    # Summer/Winter
    MonthRule.new([ 1, 5, 6, 7, 11, 12 ], /summer|winte?r|solsti[ct]/),
    # Autumn/Spring
    MonthRule.new([ 2, 3, 4, 8, 9, 10 ], /autumn|spring|equino[xc]/),
    # Months
    MonthRule.new([ 1 ], /\b(january)/),
    MonthRule.new([ 2 ], /\b(february|valentine)/),
    MonthRule.new([ 3 ], /\b(in\smarch|shamrock)/),
    MonthRule.new([ 4 ], /\b(april)/),
    MonthRule.new([ 5 ], /\b(in\smay)/),
    MonthRule.new([ 6 ], /\b(june)/),
    MonthRule.new([ 7 ], /\b(july)/),
    MonthRule.new([ 8 ], /\b(august)/),
    MonthRule.new([ 9 ], /\b(september)/),
    MonthRule.new([ 10 ], /\b(october|hallowe.?en|trick.or.treat)/),
    MonthRule.new([ 11 ], /\b(november)/),
    MonthRule.new([ 12 ], /
      \b(december|christmas|end\sof\s(the\s)?year|presents|santa|sleigh)
    /x),
    # Holiday seasons
    MonthRule.new([ 1, 12 ], /\b(new.?year|first\sday.*year)/),
    MonthRule.new([ 10, 11 ], /\b(thanksgiving|giv.*thanks)/),
    # Year-round snail season. (As the bulk of the corpus consists of haiku
    # by Kobayashi Issa, poem.exe quickly developed a fondness for snails.
    # An early classic reads: "snail / between my hands / snail".)
    MonthRule.new(1..12, /\b(snail)/),
    MonthRule.new(1..12, /\b(lockdown)/),
  ].freeze

  WEAK_RULES = [
    # Summer/Winter
    MonthRule.new([ 1, 5, 6, 7, 11, 12 ], /
      \b(bath|beach|bicycle|bike|cicada|cycl|cuckoo|field|
         heat|hot|ice.?cream|iris|jellyfish|lilac|lotus|
         meadow|mosquito|naked|nap|nud[ei]|orange|rain|
         siesta|smog|snake|sun|surf|sweat|swim|waterfall|
         grasshopper|fireworks|kimono)
      |
      \b(chill|cold|fallen.*lea[fv]|freez|frost|ic[eyi]|
         night|oyster|smog|snow|white)
    /x),
    # Autumn/Spring
    MonthRule.new([ 2, 3, 4, 8, 9, 10 ], /
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
    /x),
    # Months
    MonthRule.new([ 1 ], /\b(first)/),
    MonthRule.new([ 2 ], /\b(cupid|heart|love)/),
    MonthRule.new([ 10 ], /
      \b(afraid|bone|cemetery|cobweb|fog|fright|ghost|grave|grim|
         hallowe|haunt|headstone|pumpkin|scare|scream|skelet|skull|
         spider|spine|spook|tomb|witch|wizard)
    /x),
    MonthRule.new([ 12 ], /
      \b(bells|carol|festive|gift|jingl|joll|joy|merry|tree|twinkl)
    /x),
  ].freeze
end
