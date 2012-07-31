# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser/triple_set'
require 'triple_parser/third'

class TripleSetTest < Test::Unit::TestCase
  def setup
    @id = '9108fe02-0bbb-4ed9-890f-b454877ce12c'
    @subject = "id:#{@id}"
    @predicate = "type_is"
    @object = "Event" 
    @parts = [@subject, @predicate, @object]
  end
  
  def test_parts
    assert_equal(@parts, triple_set.parts)
  end
  
  def test_parts_with_element_containing_space
    parts_with_spaces = [@subject, 'name_is', "string:'Troops tighten grip on Taliban stronghold'"]
    assert_equal(parts_with_spaces, triple_set(parts_with_spaces).parts)
  end
  
  def test_each_part_has_name_method
    t = triple_set
    assert_equal(@subject, t.subject)
    assert_equal(@predicate, t.predicate)
    assert_equal(@object, t.object)
  end
  
  def test_type
    assert_equal('id', triple_set.subject.type)
  end
  
  def test_value
    assert_equal(@id, triple_set.subject.value)
  end
  
  def test_with_function
    t = TripleParser::TripleSet.new('var:location nearby(var:Latitude, var:Longitude, "5km")')
    assert_equal('var', t.subject.type)
    assert_equal('location', t.subject.value)
    assert_equal('function', t.predicate.type)
    assert_equal('nearby', t.predicate.value)
    arguments = [TripleParser::Third.new('var:Latitude'), TripleParser::Third.new('var:Longitude'), TripleParser::Third.new('"5km"')]
    assert_equal(arguments, t.predicate.arguments)
    assert_nil(t.object)
  end
  
  def test_with_rdf
    t = TripleParser::TripleSet.new('<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.')
    assert_equal('<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id>', t.subject)
    assert_equal('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', t.predicate)
    assert_equal('<http://purl.org/NET/c4dm/event.owl#Event>', t.object)    
  end
  
  private
  def triple_set(input = nil)
    input ||= @parts
    TripleParser::TripleSet.new(input.join(" "))
  end
end
