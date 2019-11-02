# frozen_string_literal: true

module PoemExe
  # ---------------------------------------------------------------------------
  # poem.exe generates poems using an approach based on Leonard Richardson's
  # Queneau Assembly technique. Each verse in the corpus is divided into three
  # "buckets", consisting of one opening line, zero or more middle lines, and
  # one closing line.
  #
  # The generator selects one of the patterns below, which determines the
  # number of source poems and which bucket each line will be selected from.
  # For the pattern [1, 2, 2, 3], a poem would be generated as follows:
  #
  #   1. Randomly select four poems from the corpus.
  #   2. From the first poem, select the opening line (1).
  #   3. From the second poem, randomly select a middle line (2), if any.
  #   4. From the third poem, randomly select a middle line (2), if any.
  #   5. From the fourth poem, select the closing line (3).
  #   6. Put them all together, giving a poem 2-4 lines long.
  # ---------------------------------------------------------------------------

  class VerseForm
    attr_reader :pattern

    def initialize(*pattern, keep_pauses: false)
      @pattern = pattern
      @keep_pauses = keep_pauses
    end

    def size
      pattern.size
    end

    def keep_pauses?
      @keep_pauses
    end
  end

  VERSE_FORMS = {
    haiku:
      VerseForm.new(:a, :b, :c, keep_pauses: true),
    two_lines:
      VerseForm.new(:a, :c),
    four_lines:
      VerseForm.new(:a, :b, :b, :c),
    pairs:
      VerseForm.new(:a, :c, :a, :c),
  }

  class Queneau
    def initialize(verses)
      @verses = verses
    end

    def sample
      [].tap do |lines|
        form_key = rand(5) > 0 ? :haiku : VERSE_FORMS.keys.sample
        form = VERSE_FORMS[form_key]
        verses = @verses.sample(form.size)

        form.pattern.each_with_index do |bucket, verse_index|
          line = verses[verse_index][bucket].sample
          next if line.nil?

          line = line.gsub(/\u2014|\u2026/, ' ') unless form.keep_pauses?
          lines << line
        end
      end
    end
  end
end
