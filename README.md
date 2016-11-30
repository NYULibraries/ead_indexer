# EadIndexer

[![NYU](https://github.com/NYULibraries/nyulibraries_stylesheets/blob/master/app/assets/images/nyulibraries_stylesheets/nyu.png)](https://dev.library.nyu.edu)
[![Build Status](https://travis-ci.org/NYULibraries/ead_indexer.svg?branch=master)](https://travis-ci.org/NYULibraries/ead_indexer)
[![Code Climate](https://codeclimate.com/github/NYULibraries/ead_indexer/badges/gpa.svg)](https://codeclimate.com/github/NYULibraries/ead_indexer)
[![Coverage Status](https://coveralls.io/repos/github/NYULibraries/ead_indexer/badge.svg?branch=master)](https://coveralls.io/github/NYULibraries/ead_indexer?branch=master)

## Installation

```
gem 'ead_indexer', git: "https://github.com/NYULibraries/ead_indexer"
```

### Solr

Configure a `config/solr.yml` in the client app with the `url` of the Solr instance to be used by EadIndexer.

## Usage

### Indexing EAD files

Index/Reindex a single EAD or a whole directory:

```
rake ead_indexer:index EAD=findingaids_eads/archives/adler.xml
rake ead_indexer:index EAD=findingaids_eads/archives
```

Reindex only the files in the data repository that have changed since the last commit:

```
rake ead_indexer:reindex_changed
```

Reindex only the files in the data repository that have changed since last week:

```
rake ead_indexer:reindex_changed_since_last_week
```

Reindex only the files in the data repository that have changed since yesterday:

```
rake ead_indexer:reindex_changed_since_yesterday
```

Reindex only the files in the data repository that have changed since X days ago:

```
rake ead_indexer:reindex_changed_since_days_ago[days]
```

### Delete from index

#### Warning: This will delete everything in the Solr index

**Never do this in production***

```
rake ead_indexer:clean
```

To delete all records from the index do the following in the Rails console:

```
EadIndexer::Indexer.delete_all
```

### Custom document definition

SolrEad allows for the definition of a document which overrides the default terminology when converting the EAD into a Solr document (the terminology is written in [om](https://github.com/projecthydra/om) format). This CustomDocument can be found in `lib/ead_indexer/document.rb`.

You can override this customization in the client application by creating a class that inherits from `EadIndexer::Document`, e.g.:

```
class MyApp::Ead::Document < EadIndexer::Document
```

To extend (_not_ modify) the existing customization in `lib/ead_indexer/document.rb`, use a `extend_terminology` block:

```
class MyApp::Ead::Document < EadIndexer::Document
  set_terminology do |t|
    t.root(path: "my_root")
  end
end
```

To define your own terminology from scratch, use a `set_terminology` block with the same syntax.

To register this document with EadIndexer, you need to specify it in an initializer:

```
EadIndexer.configure do |config|
  config.document_class = MyApp::Ead::Document
end
```

See the [solr_ead](https://github.com/awead/solr_ead) documentation for more information on custom documents.

### Component indexing and searching

EAD XML documents have separate components denoted by `<c>` elements, which if specified SolrEad indexes separately with a reference back to its parent EAD. Similarly to the custom `Document`, a custom `Component` can be defined and is defined by us at `lib/ead_indexer/component.rb`.

Likewise, the client application can extend or modify the existing customization in a class that inherits from `EadIndexer::Component` by using the `extend_terminology` block as above (or the `set_terminology` block to define a new terminology from scratch).

To register a custom component class with EadIndexer, you need to specify it in an initializer, e.g.:

```
EadIndexer.configure do |config|
  config.component_class = MyApp::Ead::Component
end
```

### Locales

Can override locale in client application.
