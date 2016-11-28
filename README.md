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
rake findingaids:ead:index EAD=findingaids_eads/archives/adler.xml
rake findingaids:ead:index EAD=findingaids_eads/archives
```

Reindex only the files in the data repository that have changed since the last commit:

```
rake findingaids:ead:reindex_changed
```

Reindex only the files in the data repository that have changed since last week:

```
rake findingaids:ead:reindex_changed_since_last_week
```

Reindex only the files in the data repository that have changed since yesterday:

```
rake findingaids:ead:reindex_changed_since_yesterday
```

Reindex only the files in the data repository that have changed since X days ago:

```
rake findingaids:ead:reindex_changed_since_days_ago[days]
```

### Delete from index

#### Warning: This will delete everything in the Solr index

**Never do this in production***

```
rake findingaids:ead:clean
```

To delete all records from the index do the following in the Rails console:

```
EadIndexer::Indexer.delete_all
```

### Custom document definition

SolrEad allows for the definition of a document which overrides the default terminology when converting the EAD into a Solr document (the terminology is written in [om](https://github.com/projecthydra/om) format). This CustomDocument can be found in `lib/ead_indexer/document.rb`.

You can override this customization in the client application by creating a class that inherits from `EadIndexer::Document`, e.g.:

```
MyApp::Document < EadIndexer::Document
```

To extend or modify the existing customization in `lib/ead_indexer/document.rb`, use a `extend_terminology` block. To define your own terminology from scratch, use a `set_terminology` block.

See the [solr_ead](https://github.com/awead/solr_ead) documentation for more information on custom documents.

### Locales

Can override locale in client application.
