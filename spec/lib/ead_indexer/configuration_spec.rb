require 'rails_helper'

describe EadIndexer::Configuration do
  let(:configuration){ described_class.new }

  describe "document_class" do
    subject{ configuration.document_class }
    it { is_expected.to eq EadIndexer::Document }
  end

  describe "component_class" do
    subject{ configuration.component_class }
    it { is_expected.to eq EadIndexer::Component }
  end
end
