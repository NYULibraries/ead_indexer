require 'rails_helper'

describe EadIndexer::Document do

  let(:document) { EadIndexer::Document.from_xml(ead_fixture("EAD_Tracer.xml")) }

  subject { document }

  # Check "include" because these are all multi-valued fields in Solr
  its(:eadid) { is_expected.to include "Resource-EAD-ID-AT" }
  its(:unittitle) { is_expected.to eql ["Resource--Title-AT"] }
  its(:author) { is_expected.to eql ["Finding aid prepared by Resource-FindingAidAuthor-AT"] }
  # Proxy for unittitle at the collection level
  its(:collection) { is_expected.to eql ["Resource--Title-AT"] }
  its(:unitid) { is_expected.to eql ["Resource.ID.AT.AT"] }
  its(:langcode) { is_expected.to eql ["eng"] }
  its(:unitdate_normal) { is_expected.to include "1960/1970" }
  its(:unitdate_bulk) { is_expected.to eql ["Bulk, 1960-1970"] }
  its(:unitdate_inclusive) { is_expected.to eql ["Resource-Date-Expression-AT"] }
  its(:abstract) { is_expected.to eql ["Resource-Abstract-AT"] }
  its(:creator) { is_expected.to include "CNames-PrimaryName-AT. CNames-Subordinate1-AT. CNames-Subordiate2-AT. (CNames-Number-AT) (CNames-Qualifier-AT)" }
  its(:scopecontent) { is_expected.to include "Resource-ScopeContents-AT" }
  its(:scopecontent) { is_expected.to_not include "Resource-C01-ScopecontentNoteContent-AT" }
  its(:bioghist) { is_expected.to include "Resource-BiographicalHistorical-AT" }
  its(:bioghist) { is_expected.to_not include "c06--biogHist-part1" }
  its(:acqinfo) { is_expected.to include "Resource-ImmediateSourceAcquisition" }
  its(:phystech) { is_expected.to include "Resource-PhysicalCharacteristicsTechnicalRequirements-AT" }
  its(:custodhist) { is_expected.to include "Resource--CustodialHistory-AT" }
  its(:appraisal) { is_expected.to include "Resource-Appraisal-AT" }
  its(:chronlist) { is_expected.to include "Christmas 1985" }
  its(:chronlist) { is_expected.to_not include "first date" }
  its(:corpname) { is_expected.to include "CNames-PrimaryName-AT. CNames-Subordinate1-AT. CNames-Subordiate2-AT. (CNames-Number-AT) (CNames-Qualifier-AT)" }
  its(:corpname) { is_expected.to_not include "CNames-PrimaryName-AT. CNames-Subordinate1-AT. CNames-Subordiate2-AT. (CNames-Number-AT) (CNames-Qualifier-AT) -- Pictorial works" }
  its(:famname) { is_expected.to include "FNames-FamilyName-AT, FNames-Prefix-AT, FNames-Qualifier-AT -- Archives" }
  its(:famname) { is_expected.to_not include "FNames-FamilyName-AT, FNames-Prefix-AT, FNames-Qualifier-AT -- Pictorial works" }
  its(:function) { is_expected.to include "Subjects--Function-AT" }
  its(:function) { is_expected.to_not include "c06-index1" }
  its(:genreform) { is_expected.to include "Subjects--GenreForm--AT" }
  its(:genreform) { is_expected.to_not include "Bike 1" }
  its(:geogname) { is_expected.to include "Subjects--Geographic Name--AT" }
  # No lower level examples, so make sure the value doesn't repeat
  its("geogname.count") { is_expected.to eql 1 }
  its(:name) { is_expected.to be_empty } # No examples for name
  its(:occupation) { is_expected.to include "Subjects--Occupation--AT" }
  its("occupation.count") { is_expected.to eql 1 }
  its(:persname) { is_expected.to include "PNames-Primary-AT, PNames-RestOfName-AT, PNames-Prefix-AT, PName-Number-AT, PNames-Suffix-AT, PNames-Title-AT,  (PNames-FullerForm-AT), PNames-Dates-AT, PNames-Qualifier-AT" }
  # Only 3 persnames at the top-level, don't include the lower ones
  its("persname.count") { is_expected.to eql 3 }
  its(:subject) { is_expected.to include "Subjects--Topical Term--AT" }
  its("subject.count") { is_expected.to eql 2 }
  its(:title) { is_expected.to include "Subjects--Uniform Title--AT" }
  its("title.count") { is_expected.to eql 1 }
  its(:note) { is_expected.to be_empty } # No examples for note

  describe "#heading" do
    let(:solr_doc) { document.to_solr }
    subject { solr_doc[Solrizer.solr_name("heading", :displayable)] }
    it { is_expected.to eql ["Resource--Title-AT"] }
  end

  describe "unitdate" do
    let(:solr_doc) { document.to_solr }
    subject { solr_doc[Solrizer.solr_name("unitdate", :displayable)] }
    it { is_expected.to eql ["Inclusive, Resource-Date-Expression-AT ; Bulk, 1960-1970"] }
  end

  describe "facets" do
    let(:solr_doc) { document.to_solr }
    let(:facet) { 'creator' }
    subject { solr_doc[Solrizer.solr_name(facet, :facetable)] }

    context "when the facet is Creator" do
      it { is_expected.to_not be_empty }
      its(:size) { is_expected.to be 3 }
    end
    context "when the facet is Digital Content" do
      let(:facet) { 'dao' }
      it { is_expected.to include "Online Access" }
    end
    context "when the facet is Subject" do
      let(:facet) { 'subject' }
      it { is_expected.to include "c06-index1" }
      it { is_expected.to_not include "SubjectsUgly |z Topical Term |x AT" }
      its(:size) { is_expected.to be 5 }
    end
    context "when the facet is Place" do
      let(:facet) { 'place' }
      it { is_expected.to include "Subjects--Geographic Name--AT" }
    end
    context "when the facet is Name" do
      let(:facet) { 'name' }
      it { is_expected.to_not be_empty }
      it { is_expected.to_not include "Archivists' Toolkit Migration Tracer" }
      it { is_expected.to include "CNames-PrimaryName-AT -- CNames-Subordinate1-AT -- CNames-Subordiate2-AT" }
      it { is_expected.to_not include "CNames-PrimaryName-AT |z CNames-Subordinate1-AT |x CNames-Subordiate2-AT" }
      its(:size) { is_expected.to be 17 }
    end
    context "when the facet is Collection" do
      let(:facet) { 'collection' }
      it { is_expected.to include "Resource--Title-AT" }
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

end
