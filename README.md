# Taggata [![Build Status](https://travis-ci.org/adamruzicka/taggata.svg?branch=master)](https://travis-ci.org/adamruzicka/taggata)

Ruby gem for file tagging, it can:
- scan filesystem and store metadata in database
- tag stored entries
- lookup entries matching tag queries
- add and remove tags from entries

## Installation
Clone this repository:

    $ git clone https://github.com/adamruzicka/taggata.git

And then execute:

    $ bundle install

## Usage
Scan filesystem:

    $ taggata --db-path $DATABASE scan $PATH_TO_SCAN

Search for entries:

    $ taggata --db-path $DATABASE search "$SEARCH_QUERY"

Get count of matching entries:

    $ taggata --db-path $DATABASE -c search "$SEARCH_QUERY"

Tag an entry:

    $ taggata --db-path $DATABASE tag "$SEARCH_QUERY" "$TAG_QUERY"

Remove files matching a query:

    $ taggata --db-path $DATABASE remove "$SEARCH_QUERY"

Query formats:
Search query has format of "$TYPE:$PARAMETER", where:
- $TYPE can be one of:
  - ```is``` - searches for tag
  - ```tag``` - the same as ```is```
  - ```path``` - matches against absolute paths of files
  - ```name``` - matches against name of the file
- $PARAMETER
  - for ```is``` and ```tag``` it is a string
  - for ```path``` and ```name``` it is a regular expression
- special cases
  - ```missing``` - searches for files which are present in the database but not on filesystem
  - ```untagged``` - searches for files without any tag

The search queries can be combined by using operators ```and``` and ```or``` and parentheses.
For example to get all files tagged as photos taken in year 2014 and 2015 one would issue:

    $ taggata $DATABASE search "is:photo and ( is:2014 or is:2015 )"

Tag query has format of ```+$TAG_NAME``` or ```-$TAG_NAME```, one can specify more in one query
For example to tag all untagged files containing ```Photos``` in path with tags ```photo``` and ```to-backup``` one would issue:

    $ taggata $DATABASE tag "untagged and path:Photos" "+photo +to-backup -default"

## Contributing

1. Fork it ( https://github.com/adamruzicka/taggata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
