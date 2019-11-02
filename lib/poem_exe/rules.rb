# frozen_string_literal: true

module PoemExe
  # ---------------------------------------------------------------------------
  # Poems may be accepted or rejected if they contain any seasonal reference
  # keywords. These are mostly based on the Japanese kigo (words or phrases
  # associated with particular seasons in Japan).
  #
  # As poem.exe has readers in both hemispheres, the "seasons" have been
  # simplified to two: summer-winter and autumn-spring.
  #
  # Seasonal references are categorised as either STRONG or WEAK. STRONG
  # references are mutually exclusive; WEAK references may overlap. A poem may
  # be accepted or rejected based on any STRONG references it contains; if
  # there are none, the poem will be accepted if it contains a relevant WEAK
  # reference.
  #
  # For example, "winter" is a STRONG reference. A poem containing the word
  # "winter" would be rejected in autumn-spring; in summer-winter it would be
  # accepted unless the poem also contained a STRONG reference to
  # autumn-spring.
  # ---------------------------------------------------------------------------

  STRONG_RULES = [
    {
      # summer-winter
      months: [1, 5, 6, 7, 11, 12],
      pattern: /summer|winte?r|solsti[ct]/,
    },
    {
      # autumn-spring
      months: [2, 3, 4, 8, 9, 10],
      pattern: /autumn|spring|equino[xc]/,
    },
    {
      months: [1],
      pattern: /\b(january)/,
    },
    {
      months: [2],
      pattern: /\b(february|valentine)/,
    },
    {
      months: [3],
      pattern: /\b(in\smarch|shamrock)/,
    },
    {
      months: [4],
      pattern: /\b(april)/,
    },
    {
      months: [5],
      pattern: /\b(in\smay)/,
    },
    {
      months: [6],
      pattern: /\b(june)/,
    },
    {
      months: [7],
      pattern: /\b(july)/,
    },
    {
      months: [8],
      pattern: /\b(august)/,
    },
    {
      months: [9],
      pattern: /\b(september)/,
    },
    {
      months: [10],
      pattern: /\b(october|hallowe.?en|trick.or.treat)/,
    },
    {
      months: [11],
      pattern: /\b(november)/,
    },
    {
      months: [12],
      pattern: %r{
        \b(december|christmas|end\sof\s(the\s)?year|presents|santa|sleigh)
      }x,
    },
    {
      months: [1, 12],
      pattern: /\b(new.?year|first\sday.*year)/,
    },
    {
      months: [10, 11],
      pattern: /\b(thanksgiving|giv.*thanks)/,
    },
    {
      # With the bulk of the corpus consisting of haiku by Kobayashi Issa,
      # poem.exe quickly developed its own particular fondness for snails
      # (an early classic: "snail / between my hands / snail"). This rule
      # ensures that snails are considered interesting year-round.
      months: 1..12,
      pattern: /\b(snail)/,
    },
  ]

  WEAK_RULES = [
    {
      # summer-winter
      months: [1, 5, 6, 7, 11, 12],
      pattern: %r{
        \b(bath|beach|bicycle|bike|cicada|cycl|cuckoo|field|
           heat|hot|ice.?cream|iris|jellyfish|lilac|lotus|
           meadow|mosquito|naked|nap|nud[ei]|orange|rain|
           siesta|smog|snake|sun|surf|sweat|swim|waterfall|
           grasshopper|fireworks|kimono)
        |
        \b(chill|cold|fallen.*lea[fv]|freez|frost|ic[eyi]|
           night|oyster|smog|snow|white)
      }x,
    },
    {
      # autumn-spring
      months: [2, 3, 4, 8, 9, 10],
      pattern: %r{
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
    },
    {
      months: [1],
      pattern: /\b(first)/,
    },
    {
      months: [2],
      pattern: /\b(cupid|heart|love)/,
    },
    {
      months: [10],
      pattern: %r{
        \b(afraid|bone|cemetery|cobweb|fog|fright|ghost|grave|grim|
           hallowe|haunt|headstone|pumpkin|scare|scream|skelet|skull|
           spider|spine|spook|tomb|witch|wizard)
      }x,
    },
    {
      months: [12],
      pattern: %r{
        \b(bells|carol|festive|gift|jingl|joll|joy|merry|tree|twinkl)
      }x,
    },
  ]
end
