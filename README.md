Triple parser
=============

Converts text containing RDF triples between simple and complex versions

For example:

    triples = <<EOF
    id:112121212111111111111   owl:event:time                   id:234242342342334234242432
    id:234242342342334234242432   rdf:type                         owl:timeline:Interval
    id:234242342342334234242432   owl:timeline:beginsAtDateTime    xml:date_time:'2010-02-15T12:00:00Z'
    id:234242342342334234242432   owl:timeline:endsAtDateTime      xml:date_time:'2010-02-17T12:00:00Z'
    EOF

    TripleParser.to_rdf(triples)

Outputs:

    [
      "<http://en.wikipedia.org/wiki/Triplestore/things/112121212111111111111#id> <http://purl.org/NET/c4dm/event.owl#time> <http://en.wikipedia.org/wiki/Triplestore/things/234242342342334234242432#id> .",
      "<http://en.wikipedia.org/wiki/Triplestore/things/234242342342334234242432#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval> .",
      "<http://en.wikipedia.org/wiki/Triplestore/things/234242342342334234242432#id> <http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime> "2010-02-15T12:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .",
      "<http://en.wikipedia.org/wiki/Triplestore/things/234242342342334234242432#id> <http://purl.org/NET/c4dm/timeline.owl#endsAtDateTime> "2010-02-17T12:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> ."
    ]

Setting site specific application url
-------------------------------------
The default application url is 'en.wikipedia.org/wiki/Triplestore' where you can read more about triplestores.
To change this to your site specific url, use this (in a Rails initializer for example):

    TripleParser::Settings.application_domain = 'undervale.co.uk' 

Playground
----------
A simple Sinatra site is included, where you can enter triples and see how they converted by TripleParser.to_rdf

To play:

    ruby web.rb

The page can then be viewed at http://localhost:4567
Enter your triples in the text area and click submit. The output will appear below the text area