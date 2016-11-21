require 'rails_helper'

describe EadIndexer::Behaviors::Dates do

  include EadIndexer::Behaviors::Dates

  describe "DATE_RANGES" do
    EadIndexer::Behaviors::Dates::DATE_RANGES.each do |date_range|
      subject { date_range }
      it { is_expected.to be_instance_of Hash }
    end
  end

  describe "UNDATED" do
    subject { EadIndexer::Behaviors::Dates::UNDATED }
    it { is_expected.to eql "undated & other" }
  end

  describe "#in_range?" do
    let(:unitdate_start_date) { "1900" }
    let(:unitdate_end_date) { "1910" }
    let(:date_range_end_date) { "1900" }
    let(:date_range_start_date) { "1902" }
    let(:unitdate) { "#{unitdate_start_date}/#{unitdate_end_date}" }
    let(:date_range) { { start_date: date_range_start_date, end_date: date_range_end_date } }
    subject { in_range?(unitdate, date_range)  }
    context "when unitdate start is greater than the date range start date" do
      let(:unitdate_start_date) { "1901" }
      let(:date_range_start_date) { "1899" }
      context "and the unitdate start IS less than the date range end date" do
        let(:date_range_end_date) { "1902" }
        it { is_expected.to be true }
      end
      context "and the unitdate start IS NOT less than the date range end date" do
        let(:date_range_end_date) { "1900" }
        it { is_expected.to be false }
      end
    end
    context "when unitdate end date is greater than the date range start date" do
      let(:unitdate_end_date) { "1901" }
      let(:date_range_start_date) { "1899" }
      context "and the unitdate end IS less than the date range end date" do
        let(:date_range_end_date) { "1902" }
        it { is_expected.to be true }
      end
      context "and the unitdate end IS NOT less than the date range end date" do
        let(:date_range_start_date) { "1850" }
        let(:date_range_end_date) { "1899" }
        it { is_expected.to be false }
      end
    end
    context "when the date range is incorrectly formatted" do
      let(:date_range) { { end_date: date_range_end_date } }
      it { is_expected.to be false }
    end
    context "when the unitdate is incorrectly formatted" do
      let(:unitdate) { "1900" }
      it { is_expected.to be false }
    end
  end

  describe "#unitdate_parts" do
    subject { unitdate_parts(unitdate) }
    context "when unitdate is properly normalized" do
      let(:unitdate) { "1900/1902" }
      it { is_expected.to eql ["1900","1902"] }
    end
    context "when unitdate is not properly normalized" do
      let(:unitdate) { "Bulk: 2001-2002; Unitdate: April 5th" }
      it { is_expected.to eql [] }
    end
  end

end
