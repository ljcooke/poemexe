# frozen_string_literal: true

require_relative 'rules'

module PoemExe
  def self.score(text, month:)
    score_with_strong_rules(text, month: month) ||
      score_with_weak_rules(text, month: month)
  end

  def self.score_with_strong_rules(text, month:)
    result = nil
    match_patterns(text, STRONG_RULES) do |rule|
      if rule.match_month?(month)
        result = :strong
      else
        result = :inconsistent
        break
      end
    end
    result
  end

  def self.score_with_weak_rules(text, month:)
    match_patterns(text, WEAK_RULES) do |rule|
      return :weak if rule.match_month?(month)
    end
    nil
  end

  def self.match_patterns(text, rules)
    rules.each do |rule|
      yield rule if rule.match_text?(text)
    end
  end
end
