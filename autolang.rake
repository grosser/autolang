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

require 'rtranslate'
require 'gettext/utils'
require 'hpricot'
require 'open-uri'
require 'cgi'

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)
MY_APP_TEXT_DOMAIN = "rs"

class Autolang
  def self.extract_msgid(text)
    return nil unless text =~ /^msgid/
    msgid = text.scan(/"(.+)"/).to_s.gsub(' | ','|')
    return nil if msgid.empty?
    msgid
  end

  def self.translate(text)
    e = TranslationEscaper.new(text)
    e.unescape(Translate.t(e.escaped, Language::ENGLISH, ENV['L']))
  end

  # protects text from evil translation robots
  # by ensuring phrases that should not be translated (Car|Engine, %{name}, ...)
  # stay untranslated
  class TranslationEscaper
    attr_accessor :escaped

    def initialize(text)
      @text = text
      self.escaped = escape_text
    end

    def unescape(translation)
      remove_placeholders(translation)
    end

  protected
  
    def escape_text
      @placeholders = []
      text = @text
      if text =~ /^([^\s]+\|)/
        @cut_off = $1
        text = text.sub($1,'')
      end
      text = add_placeholder(text, /(%\{.+\})/ )
      text = text.gsub('&','and')#& cannot be translated
    end

    # replace stuff that would get messed up in translation
    # through a non-translateable placeholder
    def add_placeholder(text,regex)
      if text =~ regex
        @placeholders << $1
        text = text.sub($1,"PH#{@placeholders.length-1}")
      end
      text
    end

    # swap placeholders with original values
    def remove_placeholders(text)
      @placeholders.each_index do |i|
        replaced = @placeholders[i]
        text = text.sub("PH#{i}",replaced)
      end
      text
    end
  end
end

namespace :autolang do
  desc "Translate strings into a new language."
  task :translate do
    if !ENV['L'] or !ENV['APP_NAME']
      puts "Usage: L=language_code APP_NAME=app_name rake autolang:translate"
      puts "  language_codes are 2 letter ISO 639 codes "
      puts "  app_name can be found infront of your .pot file (it called *appname*.pot) "
      puts ""
      puts "Example: Translate all msgids into Spanish."
      puts "  L=es APP_NAME=myapp rake autolang:translate"
      exit
    end

    root = ENV['PO_FOLDER'] || File.join(RAILS_ROOT,'locale')
    lang_dir = "#{root}/#{ENV['L']}"
    pot_file = "#{root}/#{ENV['APP_NAME']}.pot"
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

    # translate existing po file
    lines = []
    msgid = ""
    msgstr = ""
    puts "Translating..."
    File.foreach(po_file) do |line|
      #read string to translate
      if msgid = Autolang.extract_msgid(line)
        puts msgid
        puts msgstr = Autolang.translate(msgid)
        puts '-'*80

      #replace translation
      elsif line =~ /^msgstr/
        unless msgstr.empty?
          line = "msgstr \"#{msgstr}\""
        end
      end

      #output to po file
      lines << line.strip
    end

    #write new translation file
    File.open(po_file, "w+") do |file|
      file.write(lines*"\n")
    end
  end
end
