require 'rake'
require 'mocha'
require 'autolang'
require 'tmpdir'
require 'stringio'

EasyTranslate.api_key = ENV["API_KEY"] || File.read("spec/API_KEY").strip

describe Autolang do
  it "has a VERSION" do
    Autolang::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe :extract_msgid do
    it "finds message in text" do
      Autolang.send(:extract_msgid, 'msgid "hello"').should == 'hello'
    end

    it "does not find empty message" do
      Autolang.send(:extract_msgid, 'msgid ""').should == nil
    end

    it "does not find non-existing message" do
      Autolang.send(:extract_msgid, 'msgstr "hello"').should == nil
    end
  end

  describe :translate do
    it "can work with frozen strings" do
      Autolang.translate('hello'.freeze, 'es'.freeze).should == '¡hola'
    end

    it "translates a word" do
      Autolang.translate('hello', 'es').should == '¡hola'
    end

    it "converts html entities" do
      Autolang.translate('sales & tax', 'es').should == 'ventas y el impuesto'
    end

    it "converts html entities back" do
      Autolang.translate('"&&&"', 'es').should == '"Andandand"'
    end

    it "translates with strange signs" do
      Autolang.translate('production', 'es').should == 'producción'
    end

    it "translates with | " do
      Autolang.translate('Auto|hello', 'es').should == '¡hola'
    end

    it "translates with %{}" do
      Autolang.translate('hello %{name}', 'es').should == 'hola %{name}'
    end
  end

  describe "CLI" do
    def autolang(command)
      result = `#{File.expand_path("../../bin/autolang", __FILE__)} #{command} 2>&1`
      raise result unless $?.success?
      result
    end

    around { |test| Dir.mktmpdir { |dir| Dir.chdir(dir, &test) } }

    describe 'translate pot file' do
      it "translates all msgids" do
        File.open("xxx.pot", 'w'){|f| f.write(%Q{msgid "hello"\nmsgstr ""}) }
        autolang "#{EasyTranslate.api_key} xxx.pot de"
        File.read("de/de.po").should include(%Q{msgid "hello"\nmsgstr "Hallo"})
      end
    end

    describe 'translate json file' do
      it "translates all messages" do
        en = "xxx/en.json"
        FileUtils.mkdir("xxx")
        File.open(en, 'w'){|f| f.write(%Q{{"foo":{"bar":"hello"}}}) }
        autolang "#{EasyTranslate.api_key} #{en} de"
        JSON.load(File.read("xxx/de.json")).should == {"foo" => {"bar" => "Hallo"}}
      end
    end
  end
end

describe Autolang::TranslationEscaper do
  let(:t) { Autolang::TranslationEscaper }

  describe :escaped do
    it "replaces piped subsections" do
      e = t.new('Car|be gone')
      e.escaped.should == 'be gone'
      e.unescape('geh weg').should == 'geh weg'
    end

    it "does not replace regular pipes" do
      e = t.new('Eat my pipe | fool')
      e.escaped.should == 'Eat my pipe | fool'
      e.unescape('Iss mein Rohr | idiot').should == 'Iss mein Rohr | idiot'
    end

    it "replaces %{something}" do
      e = t.new('can i have a %{name}, please.')
      e.escaped.should == 'can i have a PH0, please.'
      e.unescape('kann ich bitte ein PH0 haben.').should == 'kann ich bitte ein %{name} haben.'
    end

    it "replaces at the end of sentences" do
      e = t.new('hello %{name}')
      e.unescape('hello PH0').should == 'hello %{name}'
    end
  end
end

