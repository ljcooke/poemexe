# frozen_string_literal: true

require 'date'
require 'json'
require 'optparse'

# -----------------------------------------------------------------------------
#
# .-----.-----.-----.--------.  .-----.--.--.-----.
# |  _  |  _  |  -__|        |__|  -__|_   _|  -__|
# |   __|_____|_____|__|__|__|__|_____|__.__|_____|
# |__|
#
# poem.exe || poem_exe
#
# MIT License
# Copyright (c) 2014-2018 Liam Cooke
#
# https://poemexe.com
# https://github.com/ljcooke/poemexe
#
# -----------------------------------------------------------------------------
#
# Social media:
#   https://twitter.com/poem_exe
#   https://poemexe.tumblr.com
#   https://botsin.space/@poem_exe
#   https://oulipo.social/@quasihaiku
#
# Poems published on social media are licensed under the
# Creative Commons Attribution 4.0 license.
#
# -----------------------------------------------------------------------------
module PoemExe
end

require_relative 'poem_exe/composer'

if $PROGRAM_NAME == __FILE__
  require_relative 'poem_exe/cli'
  PoemExe::CLI.main
end
