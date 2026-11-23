# frozen_string_literal: true

module PoemExe
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
    haiku: VerseForm.new(:a, :b, :c, keep_pauses: true),
    two_lines: VerseForm.new(:a, :c),
    four_lines: VerseForm.new(:a, :b, :b, :c),
    pairs: VerseForm.new(:a, :c, :a, :c),
  }.freeze

  class VerseForm
    HAIKU_CHANCE = 0.85

    def self.pick(key = nil, forms = VERSE_FORMS)
      key ||= :haiku if forms.include?(:haiku) && rand <= HAIKU_CHANCE
      key ||= forms.keys.sample
      forms[key]
    end
  end
end
