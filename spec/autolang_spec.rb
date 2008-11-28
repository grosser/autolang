require 'rubygems'
require 'rake'
require 'spec'
require 'mocha'
load File.join([File.dirname(__FILE__),'..','autolang.rake'])


describe Autolang do
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
    before do
      ENV['L']='es'
    end

    it "translates a word" do
      Autolang.translate('hello').should == 'hola'
    end

    it "converts html entities" do
      Autolang.translate('sales & tax').should == 'ventas y de impuestos'
    end
    
    it "converts html entities back" do
      pending do
        Autolang.translate('"&&&&"').should == '"&&&&"'
      end
    end

    it "translates with strange signs" do
      pending do
        Autolang.translate('production').should == 'producción'
      end
    end

    it "translates with | " do
      Autolang.translate('Auto|hello').should == 'hola'
    end

    it "translates with %{}" do
      Autolang.translate('hello %{name}').should == 'hola %{name}'
    end
  end
end

describe Autolang::TranslationEscaper do
  t = Autolang::TranslationEscaper
  describe :escaped do
    it "removes html entities" do
      t.new('a & b').escaped.should == 'a+%26+b'
    end

    it "is symetric for html" do
      e = t.new('a & b')
      e.unescape('a & b').should == 'a & b'
    end

    it "replaces piped subsections" do
      e = t.new('Car|be gone')
      e.escaped.should == 'be+gone'
      e.unescape('geh weg').should == 'geh weg'
    end

    it "replaces %{something}" do
      e = t.new('can i have a %{name}, please.')
      e.escaped.should == 'can+i+have+a+PH0%2C+please.'
      e.unescape('kann ich bitte ein PH0 haben.').should == 'kann ich bitte ein %{name} haben.'
    end

    it "replaces at the end of sentences" do
      e = t.new('hello %{name}')
      e.unescape('hello PH0').should == 'hello %{name}'
    end
  end
end