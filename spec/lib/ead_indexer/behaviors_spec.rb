require 'rails_helper'

describe EadIndexer::Behaviors do

  let(:behaviors){ Class.new{ extend EadIndexer::Behaviors } }

  describe "#repository_display" do

    subject { behaviors.repository_display }

    context "when EAD variable is a folder in the client application" do
      before { stub_const('ENV', {'EAD' => 'config/locales'}) }

      it { is_expected.to eql("locales") }
    end

    context "when EAD variable is a file in the client application" do
      before { stub_const('ENV', {'EAD' => 'config/locales/en.yml'}) }

      it { is_expected.to eql("locales")}
    end

    context "when there is no EAD variable" do
      before { stub_const('ENV', {'EAD' => nil}) }
      it { is_expected.to be_nil }
    end

  end

  describe "#get_language_from_code" do

    let(:language_code) { "eng" }

    subject { behaviors.get_language_from_code(language_code) }

    context "when language code is eng" do
      it { is_expected.to eql("English") }
    end

    context "when language code is ger" do
      let(:language_code) { "ger" }
      it { is_expected.to eql("German") }
    end

  end

  describe "#fix_subfield_demarcators" do
    let(:subfield) { "Long Island (N.Y.) |x History |y 17th century" }

    subject { behaviors.fix_subfield_demarcators(subfield) }

    context "when subfield is Long Island (N.Y.) |x History |y 17th century" do
      it { is_expected.to eql("Long Island (N.Y.) -- History -- 17th century")}
    end

    context "when subfield is Chemistry |w History |y 19th century" do
      let(:subfield) { "Chemistry |w History |y 19th century" }
      it { is_expected.to eql("Chemistry -- History -- 19th century")}
    end
  end


end
