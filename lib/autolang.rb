require 'rtranslate'
require 'rtranslate/language'

class Autolang
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip

  def self.extract_msgid(text)
    return nil if text.match(/^msgid/).nil?
    msgid = text.scan(/"(.+)"/)[0]
    return nil if msgid.nil?
    msgid[0].to_s.gsub(' | ','|')
  end

  def self.translate(text)
    e = TranslationEscaper.new(text)

    @translator = Translate::RTranslate.new unless @translator
    e.unescape @translator.translate(e.escaped, :from => 'ENGLISH', :to => ENV['L'].dup, :userip => '127.0.0.1')
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
