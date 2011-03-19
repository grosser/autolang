# coding: utf-8

# Copyright © 2008 Chris Blackburn <cblackburn : at : cbciweb.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# “Software”), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

require 'autolang'

namespace :autolang do
  desc "Translate strings into a new language."
  task :translate do
    if !ENV['L'] or !ENV['POT_FILE']
      puts "Usage: L=language_code POT_FILE=po/my_app.pot rake autolang:translate"
      puts "  language_codes are 2 letter ISO 639 codes "
      puts "  if you do not have a pot file, use gettext and updatepo first (google helps...)"
      puts ""
      puts "Example: Translate all msgids into Spanish."
      puts "  L=es POT_FILE=po/my_app.pot rake autolang:translate"
      exit
    end
    
    Autolang.translate_into_new_language(ENV['POT_FILE'], ENV['L'])
  end
end
