# frozen_string_literal: true

module PoemExe
  ELLIPSIS = "\u2026"

  def self.format_verse(text, options = {})
    lines = repunctuate(text.strip.downcase).split("\n")

    # collapse whitespace
    lines.map! { |line| line.split.join(' ') }

    # join the lines
    sep = options[:single_line] ? ' / ' : "\n"
    lines.join(sep)
  end

  # Replace sequences of two or more dots with an ellipsis.
  # Strip other punctuation.
  def self.repunctuate(text)
    text
      .gsub(/\.{2,}/, ELLIPSIS)
      .gsub(/[.,:;\u2014]$/, '')
  end
end
