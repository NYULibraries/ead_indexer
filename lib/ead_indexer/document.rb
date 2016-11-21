##
# Ead Document
#
# Use OM to describe an EAD finding aid document (at the top
# collection level) as XML so we can import it into Solr
class EadIndexer::Document < SolrEad::Document

  include EadIndexer::Behaviors
  include EadIndexer::Behaviors::Document

  # Define each term in your ead that you want put into the solr document
  set_terminology do |t|
    t.root(path:"ead")
    t.eadid
    t.author(path:"filedesc/titlestmt/author",index_as:[:searchable,:displayable])

    # Descriptive information in <did>
    t.unittitle(path:"archdesc[@level='collection']/did/unittitle",index_as:[:searchable,:displayable])
    t.unitid(path:"archdesc[@level='collection']/did/unitid",index_as:[:searchable,:displayable])
    t.langcode(path:"archdesc[@level='collection']/did/langmaterial/language/@langcode")
    t.abstract(path:"archdesc[@level='collection']/did/abstract",index_as:[:searchable,:displayable])
    t.creator(path:"archdesc[@level='collection']/did/origination[@label='creator']/*[#{creator_fields_to_xpath}]",index_as:[:searchable,:displayable])

    # Dates
    t.unitdate_normal(path:"archdesc[@level='collection']/did/unitdate/@normal",index_as:[:displayable,:searchable,:facetable])
    t.unitdate(path:"archdesc[@level='collection']/did/unitdate[not(@type)]",index_as:[:searchable])
    t.unitdate_bulk(path:"archdesc[@level='collection']/did/unitdate[@type='bulk']",index_as:[:searchable])
    t.unitdate_inclusive(path:"archdesc[@level='collection']/did/unitdate[@type='inclusive']",index_as:[:searchable])

    # Fulltext in <p> under the following descriptive fields
    t.scopecontent(path:"archdesc[@level='collection']/scopecontent/p",index_as:[:searchable])
    t.bioghist(path:"archdesc[@level='collection']/bioghist/p",index_as:[:searchable])
    t.acqinfo(path:"archdesc[@level='collection']/acqinfo/p",index_as:[:searchable])
    t.custodhist(path:"archdesc[@level='collection']/custodhist/p",index_as:[:searchable])
    t.appraisal(path:"archdesc[@level='collection']/appraisal/p",index_as:[:searchable])
    t.phystech(path:"archdesc[@level='collection']/phystech/p",index_as:[:searchable])

    # Find the following wherever they exist in the tree structure under <archdesc level="collection">
    # except under the inventory which starts at <dsc>
    t.chronlist(path:"archdesc[@level='collection']/*[name() != 'dsc']//chronlist/chronitem//text()",index_as:[:searchable])
    t.corpname(path:"archdesc[@level='collection']/*[name() != 'dsc']//corpname",index_as:[:searchable,:displayable])
    t.famname(path:"archdesc[@level='collection']/*[name() != 'dsc']//famname",index_as:[:searchable,:displayable])
    t.function(path:"archdesc[@level='collection']/*[name() != 'dsc']//function",index_as:[:searchable,:displayable])
    t.genreform(path:"archdesc[@level='collection']/*[name() != 'dsc']//genreform",index_as:[:searchable,:displayable])
    t.geogname(path:"archdesc[@level='collection']/*[name() != 'dsc']//geogname",index_as:[:searchable,:displayable])
    t.name(path:"archdesc[@level='collection']/*[name() != 'dsc']//name",index_as:[:searchable,:displayable])
    t.occupation(path:"archdesc[@level='collection']/*[name() != 'dsc']//occupation",index_as:[:searchable,:displayable])
    t.persname(path:"archdesc[@level='collection']/*[name() != 'dsc']//persname",index_as:[:searchable,:displayable])
    t.subject(path:"archdesc[@level='collection']/*[name() != 'dsc']//subject",index_as:[:searchable,:displayable])
    t.title(path:"archdesc[@level='collection']/*[name() != 'dsc']//title",index_as:[:searchable,:displayable])
    t.note(path:"archdesc[@level='collection']/*[name() != 'dsc']//note",index_as:[:searchable,:displayable])

    # Copy fields
    t.collection(proxy:[:unittitle],index_as:[:facetable,:displayable,:searchable])
  end

  def to_solr(solr_doc = Hash.new)
    solr_doc = super(solr_doc)

    # Populate repository code from indexing folder structure
    Solrizer.insert_field(solr_doc, "repository",   repository_display,     :stored_sortable, :facetable, :displayable)
    # Set the format to Archival Collection
    Solrizer.insert_field(solr_doc, "format",       "Archival Collection",  :facetable, :displayable)
    # Sortable element based on the type of thing this is, will help us sort by Collection, Series, etc.
    Solrizer.insert_field(solr_doc, "format",       0,                      :sortable)
    # Special formatting for some fields and facets
    Solrizer.insert_field(solr_doc, "creator",      get_ead_creators,       :displayable, :facetable)
    Solrizer.insert_field(solr_doc, "name",         get_ead_names,          :facetable, :searchable)
    Solrizer.insert_field(solr_doc, "place",        get_ead_places,         :facetable)
    Solrizer.insert_field(solr_doc, "subject",      get_ead_subject_facets, :facetable, :searchable)
    Solrizer.insert_field(solr_doc, "dao",          get_ead_dao_facet,      :facetable)
    Solrizer.insert_field(solr_doc, "material_type",get_material_type_facets,:facetable, :displayable)

    # Replace certain fields with their html-formatted equivalents
    Solrizer.set_field(solr_doc, "unittitle",       self.term_to_html("unittitle"), :displayable)
    # Use the unittitle as the heading
    Solrizer.insert_field(solr_doc, "heading",      self.unittitle,         :displayable)

    # Set start and end date fields
    solr_doc.merge!(ead_unitdate_fields)

    # Set date range facet after we have start and end dates
    Solrizer.insert_field(solr_doc, "date_range",   get_date_range_facets,  :facetable)

    # Set language codes
    solr_doc.merge!(ead_language_fields)

    return solr_doc
  end

end
