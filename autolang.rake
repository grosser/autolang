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
require 'cgi'

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)
MY_APP_TEXT_DOMAIN = "rs"

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

    root = ENV['LOCALE_FOLDER'] || RAILS_ROOT
    lang_dir = "#{root}/_po/#{ENV['L']}"
    pot_file = "#{root}/_po/#{ENV['APP_NAME']}.pot"
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
    # http://translate.google.com/translate_t?hl=en&ie=UTF8&text=What+is+your+name%3F&sl=en&tl=es
    # <div id="result_box" dir="ltr">¿Cómo te llamas?</div>
    lines = []
    msgid = ""
    msgstr = ""
    puts "Translating..."
    File.foreach(po_file) do |line|
      #read string to translate
      if line =~ /^msgid/
        msgid = line.scan(/"(.+)"/).to_s.gsub(' | ','|')
        unless msgid.empty?
          puts msgid
          begin
            url = "http://translate.google.com/translate_t?hl=en&ie=UTF8&text=#{CGI.escape(msgid)}&sl=en&tl=#{ENV['L']}"
            doc = Hpricot(open(url))
            puts msgstr = CGI.unescape(doc.search("//div[@id='result_box']").inner_html).gsub(' | ','|')
          rescue
            puts "Could not load URL: #{url}"
            msgstr = ''
          end
          puts '-'*80
        end

      #replace translation
      #TODO do not overwrite existing! <-> FORCE=1
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
