$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser'

class TripleParserTest < Test::Unit::TestCase
  

  def test_event_definitions
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c rdf:type owl:event:Event
<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.
EOF
     
    assert_equal('9108fe02-0bbb-4ed9-890f-b454877ce12c', @triples.first.subject.value)
    assert_equal('id', @triples.first.subject.type)
    assert_equal('owl:event', @triples.first.object.type)
    
    assert_first_last_match(@triples)
  end
  
  def test_string_definitions
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c domain:name xml:string:'Troops tighten grip on Taliban stronghold'
<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.bbc.co.uk/ontologies/domain/name> "Troops tighten grip on Taliban stronghold"^^<http://www.w3.org/2001/XMLSchema#string>.
EOF
    assert_first_last_match(@triples)
  end
  
  def test_interval_type
    load_triples <<EOF
id:0237eb08-e4a5-463c-baaa-5a28f2b63707 rdf:type owl:timeline:Interval
<http://www.bbc.co.uk/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval>.
EOF
    assert_first_last_match(@triples)
  end 
  
  def test_date_time
    load_triples <<EOF
id:0237eb08-e4a5-463c-baaa-5a28f2b63707 owl:timeline:beginsAtDateTime xml:date_time:'2010-02-15T12:00:00Z'
<http://www.bbc.co.uk/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime> "2010-02-15T12:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>.  
EOF
    assert_first_last_match(@triples)
  end

  def test_place
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c owl:event:place resource:United_Kingdom
<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://purl.org/NET/c4dm/event.owl#place> <http://dbpedia.org/resource/United_Kingdom>.
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
  
  def test_function
    load_triples <<EOF
?location omgeo:nearby(?Latitude, ?Longitude, "5km")   
?location omgeo:nearby(?Latitude ?Longitude "5km") . 
EOF
    assert_first_last_match(@triples)
  end
  
  def test_to_rdf
    input = %q{<http://www.bbc.co.uk/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval> .}
    output = TripleParser.to_rdf(input)
    assert_equal(input, output.first)
  end
  
  def test_multiline_to_rdf
    triple = %q{<http://www.bbc.co.uk/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval> .}
    
    input = <<EOF
<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.
id:9108fe02-0bbb-4ed9-890f-b454877ce12c rdf:type owl:event:Event
<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.bbc.co.uk/ontologies/domain/name> "Troops tighten grip on Taliban stronghold"^^<http://www.w3.org/2001/XMLSchema#string>.
id:9108fe02-0bbb-4ed9-890f-b454877ce12c domain:name string:'Troops tighten grip on Taliban stronghold'  
#{triple}
EOF
    output = TripleParser.to_rdf(input)
    assert_equal(triple, output.last)
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
