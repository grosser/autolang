require 'rtranslate'
require 'rtranslate/language'

class Autolang
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip

  def self.extract_msgid(text)
    return unless text =~ /^msgid/
    return unless msgid = text.scan(/"(.+)"/)[0]
    msgid.to_s.gsub(' | ','|')
  end

  def self.translate_into_new_language(pot_file, language)
    po_file = File.join(File.dirname(pot_file), language, "#{language}.po")

    # create directory if it does not exist
    language_dir = File.dirname(po_file)
    unless FileTest.exist?(language_dir)
      puts "Creating new language directory: #{language_dir}"
      Dir.mkdir(language_dir)
    end

    # generate po file if it does not exist
    unless FileTest.exist?(po_file)
      puts "Generating new language file: #{po_file}"
      `msginit -i #{pot_file} -o #{po_file} -l #{language} --no-translator`
    end

    lines = translate_po_file_content(File.readlines(po_file), language)
    File.open(po_file, "w+"){|f| f.write(lines*"\n") }
  end

  def self.translate_po_file_content(lines, language)
    msgstr = ""
    puts "Translating..."
    lines.map do |line|
      #read string to translate
      if msgid = extract_msgid(line)
        msgstr = translate(msgid, language)

        puts msgid
        puts msgstr
        puts '-'*80

      #replace translation
      elsif line =~ /^msgstr/ and not msgstr.empty?
        line = "msgstr \"#{msgstr}\""
      end

      line.strip
    end
  end

  def self.translate(text, language)
    e = TranslationEscaper.new(text)
    @translator = Translate::RTranslate.new unless @translator
    e.unescape @translator.translate(e.escaped, :from => 'ENGLISH', :to => language, :userip => '127.0.0.1')
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
