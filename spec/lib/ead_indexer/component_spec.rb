require 'rails_helper'

##
# Test as much of the index structure of the component as possible from the examples available to us
describe EadIndexer::Component do

  let(:document) { EadIndexer::Component.from_xml(ead_fixture("ead_series.xml")) }

  subject { document }

  context "when component is series level" do
    its(:unittitle) { is_expected.to eql ["Resource-C02-AT"] }
    its(:level) { is_expected.to eql ["series"] }
    its(:container_label) { is_expected.to eql ["Text (Resource C02 Instance Barcode)"] }
    its(:container_type) { is_expected.to eql ["Box", "Folder", "Item"] }
    its(:container_id) { is_expected.to eql ["cid2"] }
    its(:unitid) { is_expected.to eql ["Resource-C02-ID-AT"] }
    its(:langcode) { is_expected.to eql ["eng"] }
    its(:unitdate_normal) { is_expected.to eql ["1999/2000", "1999/2000"] }
    its(:unitdate_inclusive) { is_expected.to eql ["Resource-C01-Date-AT"] }
    its(:unitdate_bulk) { is_expected.to eql ["Bulk, 1999-2000"] }
    its(:creator) { is_expected.to eql ["PNames-Primary-AT, PNames-RestOfName-AT, PNames-Prefix-AT, PName-Number-AT, PNames-Suffix-AT, PNames-Title-AT,  (PNames-FullerForm-AT), PNames-Dates-AT, PNames-Qualifier-AT"] }
    its(:scopecontent) { is_expected.to eql ["Resource-C01-ScopecontentNoteContent-AT"] }
    its(:bioghist) { is_expected.to be_blank }
    its(:address) { is_expected.to be_blank }
    its(:appraisal) { is_expected.to be_blank }
    its(:chronlist) { is_expected.to be_blank }
    its(:corpname) { is_expected.to_not be_blank }
    its("corpname.count") { is_expected.to eql 1 }
    its(:famname) { is_expected.to_not be_blank }
    its(:function) { is_expected.to_not be_blank }
    its(:genreform) { is_expected.to_not be_blank }
    its(:geogname) { is_expected.to_not be_blank }
    its(:phystech) { is_expected.to_not be_blank }
    its(:name) { is_expected.to be_blank }
    its(:occupation) { is_expected.to_not be_blank }
    its(:persname) { is_expected.to include "PNames-Primary-AT, PNames-RestOfName-AT, PNames-Prefix-AT, PName-Number-AT, PNames-Suffix-AT, PNames-Title-AT,  (PNames-FullerForm-AT), PNames-Dates-AT, PNames-Qualifier-AT" }
    its(:subject) { is_expected.to eql ["Subjects--Topical Term--AT"] }
    its(:title) { is_expected.to_not be_blank }
    its(:note) { is_expected.to be_blank }
    its(:dao) { is_expected.to eql ["DO.Title-AT, 1999-2000 (DO.Label-AT)"] }
  end

  context "when component is file level" do
    let(:document) { EadIndexer::Component.from_xml(ead_fixture("ead_file.xml")) }

    its(:unittitle) { is_expected.to eql ["Resource-C06-AT"] }
    its(:level) { is_expected.to eql ["file"] }
    its(:container_label) { is_expected.to eql ["Text (Resource C06 Instance Barcode)"] }
    its(:container_type) { is_expected.to eql ["Box", "Folder", "Item"]}
    its(:container_id) { is_expected.to eql ["cid6"] }
    its(:unitid) { is_expected.to eql ["Resource-C06-ID-AT"] }
    its(:langcode) { is_expected.to eql ["eng"] }
    its(:unitdate_inclusive) { is_expected.to eql ["Resource-C06-Date-AT"] }
    its(:unitdate_bulk) { is_expected.to eql ["Bulk, 1960-1970"] }
    its(:unitdate_normal) { is_expected.to eql ["1960/1970", "1960/1970"] }
    its(:creator) { is_expected.to include "CNames-PrimaryName-AT. CNames-Subordinate1-AT. CNames-Subordiate2-AT. (CNames-Number-AT) (CNames-Qualifier-AT)" }
    its("creator.count") { is_expected.to eql 3 }
    its(:scopecontent) { is_expected.to be_blank }
    its(:bioghist) { is_expected.to eql ["c06--biogHist-part1", "Resource-c06-BiogHist-EndPart"] }
    its(:address) { is_expected.to be_blank }
    its(:appraisal) { is_expected.to be_blank }
    its(:chronlist) { is_expected.to_not be_blank }
    its(:corpname) { is_expected.to include "CNames-PrimaryName-AT. CNames-Subordinate1-AT. CNames-Subordiate2-AT. (CNames-Number-AT) (CNames-Qualifier-AT)" }
    its("corpname.count") { is_expected.to eql 2 }
    its(:famname) { is_expected.to include "c06-index2" }
    its("famname.count") { is_expected.to eql 3 }
    its(:function) { is_expected.to eql ["c06-index1", "Subjects--Function-AT"] }
    its(:genreform) { is_expected.to eql ["Subjects--GenreForm--AT", "SubjectsUgly |z GenreForm |x AT"] }
    its(:geogname) { is_expected.to eql ["Subjects--Geographic Name--AT"] }
    its(:name) { is_expected.to be_blank }
    its(:occupation) { is_expected.to eql ["Subjects--Occupation--AT"] }
    its(:persname) { is_expected.to include "PNames-Primary-AT, PNames-RestOfName-AT, PNames-Prefix-AT, PName-Number-AT, PNames-Suffix-AT, PNames-Title-AT,  (PNames-FullerForm-AT), PNames-Dates-AT, PNames-Qualifier-AT" }
    its("persname.count") { is_expected.to eql 3 }
    its(:subject) { is_expected.to eql ["Subjects--Topical Term--AT", "SubjectsUgly |z Topical Term |x AT"] }
    its("subject.count") { is_expected.to eql 2 }
    its(:title) { is_expected.to eql ["Subjects--Uniform Title--AT"] }
    its(:note) { is_expected.to be_blank }
    its(:dao) { is_expected.to eql ["DO.Title-AT, 1999-2000 (DO.Label-AT)"] }
  end

  describe "#to_solr" do
    let(:additional_fields) do
      {
        "id"                                                        => "TEST-0001ref010",
        Solrizer.solr_name("ead", :stored_sortable)                 => "TEST-0001",
        Solrizer.solr_name("parent", :stored_sortable)              => "ref001",
        Solrizer.solr_name("parent", :displayable)                  => ["ref001", "ref002", "ref003"],
        Solrizer.solr_name("parent_unittitles", :displayable)       => ["Series I", "Subseries A", "Subseries 1"],
        Solrizer.solr_name("component_children", :type => :boolean) => false,
        Solrizer.solr_name("collection", :facetable)                => ["Resource--Title-AT"],
        Solrizer.solr_name("collection_unitid", :displayable)       => ["Resource.ID.AT.AT"],
        Solrizer.solr_name("author", :searchable)                   => ["Finding aid prepared by Resource-FindingAidAuthor-AT"]
      }
    end
    let(:document) { EadIndexer::Component.from_xml(ead_fixture("ead_file.xml")) }
    let(:solr_doc) { document.to_solr(additional_fields) }

    describe "chronlist" do
      subject { solr_doc[Solrizer.solr_name("chronlist", :searchable)] }
      it { is_expected.to eql ["1895", "Event1", "Event2", "1995", "Event A", "Event B"] }
    end

    describe "author" do
      subject { solr_doc[Solrizer.solr_name("author", :searchable)] }
      it { is_expected.to eql ["Finding aid prepared by Resource-FindingAidAuthor-AT"] }
    end

    describe "unitdate" do
      subject { solr_doc[Solrizer.solr_name("unitdate", :displayable)] }
      it { is_expected.to eql ["Inclusive, Resource-C06-Date-AT ; Bulk, 1960-1970"] }
    end

    describe "collection_unitid" do
      subject { solr_doc[Solrizer.solr_name("collection_unitid", :displayable)] }
      it { is_expected.to eql ["Resource.ID.AT.AT"] }
    end

    describe "facets" do
      subject { solr_doc[Solrizer.solr_name(facet, :facetable)] }
      context "when the facet is Creator" do
        let(:facet) { 'creator' }
        it { is_expected.to_not be_blank }
        its(:count) { is_expected.to eql 3 }
      end
      context "when the facet is Subject" do
        let(:facet) { 'subject' }
        it { is_expected.to include "c06-index1" }
        it { is_expected.to_not include "SubjectsUgly |z Topical Term |x AT" }
        its(:size) { is_expected.to be 5 }
      end
      context "when the facet is Format" do
        let(:facet) { 'format' }
        context "when the component is a file" do
          it { is_expected.to eql ["Archival Object"] }
        end
        context "when the component is a series" do
          let(:document) { EadIndexer::Component.from_xml(ead_fixture("ead_series.xml")) }
          let(:solr_doc) { document.to_solr(additional_fields) }
          it { is_expected.to eql ["Archival Series"] }
        end
      end
      context "when the facet is Name" do
        let(:facet) { 'name' }
        it { is_expected.to_not be_blank }
        its(:count) { is_expected.to eql 8 }
        it { is_expected.to_not include "PNames-Primary-AT-Ugly |z PNames-RestOfName-AT-Ugly" }
        it { is_expected.to include "PNames-Primary-AT-Ugly -- PNames-RestOfName-AT-Ugly" }
      end
      context "when the facet is Digital Access" do
        let(:facet) { 'dao' }
        it { is_expected.to eql ["Online Access"] }
      end
      context "when the facet is Place" do
        let(:facet) { 'place' }
        it { is_expected.to eql ["Subjects--Geographic Name--AT"] }
      end
      context "when the facet is Collection" do
        let(:facet) { 'collection' }
        it { is_expected.to eql ["Resource--Title-AT"] }
      end
      context "when the facet is Series" do
        let(:facet) { 'series' }
        it { is_expected.to eql ["Series I", "Subseries A", "Subseries 1"] }
      end
      context "when the facet is Unitdate Start" do
        let(:facet) { 'unitdate_start' }
        it { is_expected.to eql ["1960"] }
      end
      context "when the facet is Unitdate End" do
        let(:facet) { 'unitdate_end' }
        it { is_expected.to eql ["1970"] }
      end
      context "when the facet is Date Range" do
        let(:facet) { 'date_range' }
        it { is_expected.to eql ["1901-2000"] }
      end
    end


    describe "#location_display" do
      subject { solr_doc[Solrizer.solr_name("location", :displayable)] }
      it { is_expected.to eql ["Box: 6, Folder: 6, Item: 6"] }
    end

    describe "#heading" do
      subject { solr_doc[Solrizer.solr_name("heading", :displayable)] }
      it { is_expected.to eql ["Resource-C06-AT"] }
    end
  end

end
