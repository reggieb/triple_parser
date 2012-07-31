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
