require 'rake'
require 'mocha'
require 'autolang'
require 'tmpdir'

EasyTranslate.api_key = File.read("spec/API_KEY").strip

describe Autolang do
  it "has a VERSION" do
    Autolang::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe :extract_msgid do
    it "finds message in text" do
      Autolang.extract_msgid('msgid "hello"').should == 'hello'
    end

    it "does not find empty message" do
      Autolang.extract_msgid('msgid ""').should == nil
    end

    it "does not find non-existing message" do
      Autolang.extract_msgid('msgstr "hello"').should == nil
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
end

describe Autolang::TranslationEscaper do
  t = Autolang::TranslationEscaper
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

describe 'translate pot file' do
  let(:pot) { 'xxx.pot' }
  let(:po) { 'de/de.po' }
  around { |test| Dir.mktmpdir { |dir| Dir.chdir(dir, &test) } }

  before do
    File.open(pot, 'w'){|f| f.write(%Q{msgid "hello"\nmsgstr ""}) }
  end

  it "translates all msgids" do
    if system("which msginit")
      `./bin/autolang #{EasyTranslate.api_key} #{pot} de`
      File.read(po).should include(%Q{msgid "hello"\nmsgstr "hallo"})
    end
  end
end
