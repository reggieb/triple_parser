$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser'

class TripleParserTest < Test::Unit::TestCase
  

  def test_event_definitions
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c type_is Event
<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.
EOF
     
    assert_equal('9108fe02-0bbb-4ed9-890f-b454877ce12c', @triples.first.subject.value)
    assert_equal('id', @triples.first.subject.type)
    assert_equal('event', @triples.first.object.type)
    
    assert_first_last_match(@triples)
  end
  
  def test_string_definitions
    load_triples <<EOF
id:9108fe02-0bbb-4ed9-890f-b454877ce12c name_is string:'Troops tighten grip on Taliban stronghold'
<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.bbc.co.uk/ontologies/domain/name> "Troops tighten grip on Taliban stronghold"^^<http://www.w3.org/2001/XMLSchema#string>.
EOF
    assert_first_last_match(@triples)
  end
  
  def test_interval_type
    load_triples <<EOF
id:0237eb08-e4a5-463c-baaa-5a28f2b63707 type_is Interval
<http://www.bbc.co.uk/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/timeline.owl#Interval>.
EOF
    assert_first_last_match(@triples)
  end 
  
  def test_date_time
    load_triples <<EOF
id:0237eb08-e4a5-463c-baaa-5a28f2b63707 begins_at_date_time date_time:'2010-02-15T12:00:00Z'
<http://www.bbc.co.uk/things/0237eb08-e4a5-463c-baaa-5a28f2b63707#id> <http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime> "2010-02-15T12:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>.  
EOF
    assert_first_last_match(@triples)
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
        assert_equal(
          triples.first.send(third).send(method), 
          triples.last.send(third).send(method), 
          "first.#{third}.#{method} should match last.#{third}.#{method}"
        )
      end
    end
    
  end
  
  
end
