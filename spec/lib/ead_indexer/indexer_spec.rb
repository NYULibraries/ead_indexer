require 'rails_helper'

describe EadIndexer::Indexer do

  let(:indexer) { EadIndexer::Indexer.new('./spec/support/fixtures') }
  let(:message) { "Deleting file tamwag/TAM.075-ead.xml EADID='tam_075', Deleting file tamwag/WAG.221-ead.xml EADID='wag_221'" }

  before do
    allow_any_instance_of(EadIndexer::Indexer).to receive(:puts).and_return nil
  end

  describe '.delete_all' do
    pending
  end

  describe '#index' do
    subject { indexer.index(file) }
    context 'when file is not passed in' do
      let(:file) { nil }
      it 'should throw an argument error' do
        expect { subject }.to raise_error ArgumentError
      end
    end
    context 'when file is passed in' do
      let(:file) { fixture_filepath('fales','bloch.xml') }
      context 'and file is valid' do
        before { expect(indexer.indexer).to receive(:update).with(file).and_return true }
        it 'should index file' do
          expect(subject).to be true
        end
      end
      context 'and file is invalid' do
        before { expect(indexer.indexer).to receive(:update).with(file).and_raise Errno::ENOENT }
        it 'should not index file' do
          expect{ subject }.to raise_error Errno::ENOENT
        end
      end
    end
    context 'when file is a directory' do
      let(:file) { fixture_filepath('tamwag') }
      it 'should index files in directory' do
        expect(indexer.indexer).to receive(:update).with(fixture_filepath('tamwag', 'OH.002-ead.xml')).and_return true
        expect(indexer.indexer).to receive(:update).with(fixture_filepath('tamwag', 'photos_114.xml')).and_return true
        expect(indexer.indexer).to receive(:update).with(fixture_filepath('tamwag', 'PHOTOS.107-ead.xml')).and_return true
        expect(subject).to be true
      end
    end
  end

  describe '#update_or_delete' do
    before do
      allow(indexer.indexer).to receive(:update).and_return(true)
      allow(indexer.indexer).to receive(:delete).and_return(true)
    end
    subject { indexer.send(:update_or_delete, status, file, message) }
    context 'when file exists' do
      let(:file) { fixture_filepath('fales/bytsura.xml') }
      let(:status) { 'M' }
      it { is_expected.to be true }
    end
    context 'when file does not exist' do
      let(:file) { fixture_filepath('nothing_here') }
      context 'and status is Delete' do
        let(:status) { 'D' }
        it { is_expected.to be true }
      end
      context 'and status IS NOT Delete' do
        let(:status) { 'M' }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#reindex_changed_since_last_commit' do
    before { allow(indexer).to receive(:reindex_changed).and_return(true) }
    subject { indexer.send(:reindex_changed_since_last_commit) }
    it { is_expected.to be true }
  end

  describe '#reindex_changed_since_yesterday' do
    before { allow(indexer).to receive(:reindex_changed).and_return(true) }
    subject { indexer.send(:reindex_changed_since_yesterday) }
    it { is_expected.to be true }
  end

  describe '#reindex_changed_since_last_week' do
    before { allow(indexer).to receive(:reindex_changed).and_return(true) }
    subject { indexer.send(:reindex_changed_since_last_week) }
    it { is_expected.to be true }
  end

  describe '#reindex_changed_since_days_ago' do
    context 'when given a valid number of days' do
      subject { indexer.send(:reindex_changed_since_days_ago, 0) }
      it { is_expected.to be true }
    end

    context 'when given an invalid number of days' do
      subject { indexer.send(:reindex_changed_since_days_ago, 'foo') }
      it 'should throw an argument error' do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#reindex_changed' do
    before { allow(indexer).to receive(:update_or_delete).and_return(true) }
    subject { indexer.send(:reindex_changed, indexer.send(:commits)) }
    it { is_expected.to be true }
  end

  describe '#update' do
    let(:file) { fixture_filepath('fales/bytsura.xml') }
    subject { indexer.send(:update, file) }
    before { allow_any_instance_of(SolrEad::Indexer).to receive(:update).and_return(true) }
    context 'when file is not passed in' do
      let(:file) { nil }
      it 'should throw an argument error' do
        expect { subject }.to raise_error ArgumentError
      end
    end
    context 'when file is passed in' do
      it { is_expected.to be true }
    end
    context 'when SolrEad::Indexer.update fails' do
      before { allow_any_instance_of(SolrEad::Indexer).to receive(:update).and_raise ArgumentError.new }
      it "should raise error" do
        expect{ subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#delete' do
    let(:file) { fixture_filepath('fales/bytsura.xml') }
    let(:eadid) { 'bytsura' }
    subject { indexer.send(:delete, file, eadid) }
    context 'when file is not passed in' do
      before { allow(indexer.indexer).to receive(:delete).and_return(true) }
      let(:file) { nil }
      it 'should throw an argument error' do
        expect { subject }.to raise_error ArgumentError
      end
    end
    context 'when file is passed in' do
      before { allow(indexer.indexer).to receive(:delete).and_return(true) }
      context 'and eadid is passed in' do
        it { is_expected.to be true }
      end
      context 'but eadid is not passed in' do
        let(:eadid) { nil }
        it { is_expected.to be true }
      end
    end
    context 'when SolrEad::Indexer.delete fails' do
      before { allow(indexer.indexer).to receive(:delete).and_raise ArgumentError.new }
      it "should raise error" do
        expect{ subject }.to raise_error ArgumentError
      end
    end
  end

  describe '#commits' do
    subject { indexer.send(:commits) }
    it { is_expected.to_not be_nil }
    it { is_expected.to be_a Array }
  end

 describe '#changed_files' do
   subject { indexer.send(:changed_files, indexer.send(:commits)) }
   it { is_expected.to_not be_nil }
   it { is_expected.to be_a Array }
 end

 describe '#get_eadid_from_message' do
   let(:filename) { "tamwag/WAG.221-ead.xml" }
   subject { indexer.send(:get_eadid_from_message, filename, message)}
   context 'when commit message contains multiple deletes' do
     it { is_expected.to eql 'wag_221' }
   end
   context 'when commit message contains multiple updates' do
     let(:message) { "Updating file tamwag/oh_065.xml, Updating file tamwag/tam_085.xml" }
     let(:filename) { "tamwag/oh_065.xml" }
     it { is_expected.to be_nil }
   end
   context 'when commit message does not contain the filename' do
     let(:filename) { "tamwag/notthere.xml" }
     it { is_expected.to be_nil }
   end
   context 'when commit message contains a single update' do
     let(:message) { "Updating file tamwag/wag_221.xml" }
     it { is_expected.to be_nil }
   end
   context 'when commit message contains a single delete' do
     let(:message) { "Deleting file tamwag/WAG.221-ead.xml EADID='wag_221'" }
     it { is_expected.to eql 'wag_221' }
   end
 end

end
