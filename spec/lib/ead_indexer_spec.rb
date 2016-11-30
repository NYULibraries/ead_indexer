require 'rails_helper'

describe EadIndexer do
  describe "self.configuration" do
    subject{ described_class.configuration }
    it { is_expected.to be_a EadIndexer::Configuration }
  end

  describe "self.configure" do
    context "when used to set document_class" do
      subject do
        described_class.configure do |config|
          config.document_class = DummyDocument
        end
      end
      let(:fake_class){ Class.new }
      before { stub_const("DummyDocument", fake_class) }
      it "should set document_class" do
        subject
        expect(described_class.configuration.document_class).to eq DummyDocument
      end
    end

    context "when used to set document_class" do
      subject do
        described_class.configure do |config|
          config.component_class = DummyComponent
        end
      end
      let(:fake_class){ Class.new }
      before { stub_const("DummyComponent", fake_class) }
      it "should set component_class" do
        subject
        expect(described_class.configuration.component_class).to eq DummyComponent
      end
    end
  end
end
