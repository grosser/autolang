require 'easy_translate'

module Autolang
  def self.extract_msgid(text)
    return unless text =~ /^msgid/
    return unless msgid = text.scan(/"(.+)"/)[0]
    msgid.first.to_s.gsub(' | ','|')
  end

  def self.translate_into_new_language(key, file, language)
    EasyTranslate.api_key = key
    if file.end_with?(".json")
      translate_json_into_new_file(file, language)
    else
      translate_gettext_into_new_file(file, language)
    end
  end

  def self.translate_gettext_into_new_file(pot_file, language)
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
      unless $?.success?
        raise "Error during initialization, make sure gettext is installed"
      end
    end

    lines = translate_po_file_content(File.readlines(po_file), language)
    File.open(po_file, "w+") { |f| f.write(lines*"\n") }
  end

  def self.translate_json_into_new_file(file, language)
    require 'json'
    out = File.join(File.dirname(file), "#{language}.json")
    old = JSON.load(File.read(file))
    new = translate_hash(old, language)
    File.open(out, "w+") { |f| f.write(JSON.dump(new)) }
  end

  def self.translate_hash(hash, language)
    hash.inject({}) do |all, (k,v)|
      all[k] = if v.is_a?(String)
        translate(v, language)
      elsif v.is_a?(Hash)
        translate_hash(v, language)
      else
        v
      end
      all
    end
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
    e.unescape EasyTranslate.translate(e.escaped, :to => language, :format => 'html')
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
