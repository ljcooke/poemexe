# frozen_string_literal: true

require_relative 'rules'

module PoemExe
  def self.score(text, month:)
    score_with_strong_rules(text, month: month) ||
      score_with_weak_rules(text, month: month)
  end

  def self.score_with_strong_rules(text, month:)
    result = nil
    STRONG_RULES.each do |rule|
      next unless rule[:pattern].match(text)

      if rule[:months].include? month
        result = :strong
      else
        return :inconsistent
      end
    end
    result
  end

  def self.score_with_weak_rules(text, month:)
    WEAK_RULES.each do |rule|
      next unless rule[:pattern].match(text)

      return :weak if rule[:months].include? month
    end
    nil
  end
end
