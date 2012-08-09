$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser'

class TripleParserTest < Test::Unit::TestCase
  

  def test_event_definitions
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c rdf:type owl:event:Event
<http://#{TripleParser::Settings.application_domain}/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.
EOF
     
    assert_equal('9108fe02-0bbb-4ed9-890f-b454877ce12c', @triples.first.subject.value)
    assert_equal('id', @triples.first.subject.type)
    assert_equal('owl:event', @triples.first.object.type)
    
    assert_first_last_match(@triples)
  end
  
  def test_string_definitions
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c domain:name xml:string:'Troops tighten grip on Taliban stronghold'
<http://#{TripleParser::Settings.application_domain}/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.bbc.co.uk/ontologies/domain/name> "Troops tighten grip on Taliban stronghold"^^<http://www.w3.org/2001/XMLSchema#string>.
EOF
    assert_first_last_match(@triples)
  end
  
  def test_regional_text_definitions
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c domain:name text:en:'Troops tighten grip on Taliban stronghold'
<http://#{TripleParser::Settings.application_domain}/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.bbc.co.uk/ontologies/domain/name> "Troops tighten grip on Taliban stronghold"@en .
EOF
    assert_first_last_match(@triples)
  end
  
  def test_interval_type
    load_triples <<EOF
id:0237eb08-e4a5-463c-baaa-5a28f2b63707 rdf:type owl:timeline:Interval
<http://#{TripleParser::Settings.application_domain}/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval>.
EOF
    assert_first_last_match(@triples)
  end 
  
  def test_date_time
    load_triples <<EOF
id:0237eb08-e4a5-463c-baaa-5a28f2b63707 owl:timeline:beginsAtDateTime xml:date_time:'2010-02-15T12:00:00Z'
<http://#{TripleParser::Settings.application_domain}/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime> "2010-02-15T12:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>.  
EOF
    assert_first_last_match(@triples)
  end

  def test_place
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c owl:event:place resource:United_Kingdom
<http://#{TripleParser::Settings.application_domain}/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://purl.org/NET/c4dm/event.owl#place> <http://dbpedia.org/resource/United_Kingdom>.
EOF
    assert_first_last_match(@triples)
  end
  
  def test_latitude
    load_triples <<EOF
resource:United_Kingdom geo-pos:lat ?Latitude  
<http://dbpedia.org/resource/United_Kingdom> geo-pos:lat ?Latitude .
EOF
    assert_first_last_match(@triples)
  end
  
  def test_asset
    load_triples <<EOF
<http://demivee.com/8298>  rdf:type asset:Story
<http://demivee.com/8298> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.bbc.co.uk/ontologies/asset/Story>
EOF
    assert_first_last_match(@triples)
  end
  
  def test_function
    load_triples <<EOF
?location omgeo:nearby(?Latitude ?Longitude "5km")   
?location omgeo:nearby(?Latitude ?Longitude "5km") . 
EOF
    assert_first_last_match(@triples)
  end
  
  def test_to_rdf
    input = %Q{<http://#{TripleParser::Settings.application_domain}/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval> .}
    output = TripleParser.to_rdf(input)
    assert_equal(input, output.first)
  end
  
  def test_multiline_to_rdf
    triple = %Q{<http://#{TripleParser::Settings.application_domain}/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval> .}
    
    input = <<EOF
<http://#{TripleParser::Settings.application_domain}/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.
id:9108fe02-0bbb-4ed9-890f-b454877ce12c rdf:type owl:event:Event
<http://#{TripleParser::Settings.application_domain}/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.bbc.co.uk/ontologies/domain/name> "Troops tighten grip on Taliban stronghold"^^<http://www.w3.org/2001/XMLSchema#string>.
id:9108fe02-0bbb-4ed9-890f-b454877ce12c domain:name string:'Troops tighten grip on Taliban stronghold'  
#{triple}
EOF
    output = TripleParser.to_rdf(input)
    assert_equal(triple, output.last)
  end
  
  def test_actual
    triples = <<EOF
<http://meemm.edu/9600> <http://purl.org/dc/terms/title> "lorem ipsum dolor sit amet44585"@en .
<http://meemm.edu/9600> <http://purl.org/dc/terms/description> "lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante ipsum"@en .
<http://meemm.edu/9600> <http://purl.org/dc/terms/created> "2012-08-08T03:51:41Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .
<http://meemm.edu/9600> <http://purl.org/dc/terms/subject> "lorem ipsum37952"@en .
<http://meemm.edu/9600> <http://purl.org/dc/terms/identifier> "01255" .
<http://meemm.edu/9600> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.bbc.co.uk/ontologies/asset/Story> .
<http://meemm.edu/9600> <http://purl.org/dc/terms/publisher> <> .
<http://meemm.edu/9600> <http://purl.org/dc/terms/valid> "2012-08-08T03:51:41Z"^^<http://www.w3.org/2001/XMLSchema#dateTime> .    
EOF
    first_triple = "<http://meemm.edu/9600> <http://purl.org/dc/terms/title> \"lorem ipsum dolor sit amet44585\"@en ."
    
    last_triple = "<http://meemm.edu/9600> <http://purl.org/dc/terms/valid> \"2012-08-08T03:51:41Z\"^^<http://www.w3.org/2001/XMLSchema#dateTime> ."
    
    output = TripleParser.to_rdf(triples)
    assert_equal(first_triple, output.first)
    assert_equal(last_triple, output.last)
  end
    
  def load_triples(input_text)
    TripleParser.input(input_text)
    @triples = TripleParser.triples
  end
  
  def assert_first_last_match(triples)
    
    thirds = %w{subject predicate object}
    third_methods = %w{value type arguments}
    
    for third in thirds
      for method in third_methods
        if triples.first.send(third)
          assert_equal(
            triples.first.send(third).send(method), 
            triples.last.send(third).send(method), 
            "first.#{third}.#{method} should match last.#{third}.#{method}"
          )
        else
          assert_equal(triples.first.send(third), triples.last.send(third))
        end
      end
    end
    
  end
  
  
end
