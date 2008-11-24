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

require 'gettext/utils'
require 'hpricot'
require 'open-uri'

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)
MY_APP_TEXT_DOMAIN = "appname"
MY_APP_VERSION     = "appname 1.0.0"

class Autolang
  def self.cook_string(str)
    cooked = str.gsub(/\|/, ' &#124; ')
    cooked.gsub(/ /, '%20')
  end

  def self.reconstitute_string(str)
    str.gsub(/ &#124; /, '|') || str
  end
end

namespace :autolang do
  desc "Translate strings into a new language."
  task :translate do
    if !ENV['L']
      puts "Usage: L=ll rake autolang:translate"
      puts "  # Translate the strings into Spanish."
      puts "  L=es rake autolang:translate"
      exit
    end

    lang_dir = "#{RAILS_ROOT}/po/#{ENV['L']}"
    pot_file = "#{RAILS_ROOT}/po/#{MY_APP_TEXT_DOMAIN}.pot"
    po_file = "#{lang_dir}/#{ENV['L']}.po"

    # If the directory doesn't exist created it
    if !FileTest.exist?(lang_dir)
      puts "Creating new language directory: #{lang_dir}"
      Dir.mkdir(lang_dir)
    end

    # copy the main po file if it doesn't exist
    if !FileTest.exist?(po_file)
      puts "Generating new language file: #{po_file}"
      `msginit -i #{pot_file} -o #{po_file} -l #{ENV['L']}`
    end

    # translate
    # http://translate.google.com/translate_t?hl=en&ie=UTF8&text=What+is+your+name%3F&sl=en&tl=es
    # <div id="result_box" dir="ltr">¿Cómo te llamas?</div>
    translation = ""
    msgid = ""
    msgstr = ""
    puts "Translating..."
    IO.foreach("#{lang_dir}/#{ENV['L']}.po") do |line|
      baked = line.chomp
      if baked =~ /^msgid/
        msgid = Autolang.cook_string(baked.scan(/"(.+)"/).to_s)
        unless msgid.empty?
          doc = Hpricot(open("http://translate.google.com/translate_t?hl=en&ie=UTF8&text=#{msgid}&sl=en&tl=#{ENV['L']}"))
          msgstr = doc.search("//div[@id='result_box']")
        end
      elsif line =~ /^msgstr/
        unless msgstr.nil? or msgstr.empty?
          baked = "msgstr \"#{Autolang.reconstitute_string(msgstr.inner_html)}\""
        end
      end
      translation << "#{baked}\n"
    end
    File.open("#{lang_dir}/#{ENV['L']}.po", "w+") do |file|
      file.write(translation)
    end
  end
end
