require_relative 'triple_parser'

text = <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c rdf:type owl:event:Event
id:9108fe02-0bbb-4ed9-890f-b454877ce12c domain:name xml:string:'Troops tighten grip on Taliban stronghold'
id:9108fe02-0bbb-4ed9-890f-b454877ce12c owl:event:time id:0237eb08-e4a5-463c-baaa-5a28f2b63707
<http://www.undervale.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.
EOF

TripleParser.input(text)

triples = TripleParser.triples

triples.each do |t|
  p t.object.value
end
