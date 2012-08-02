# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser/triple_set'
require 'triple_parser/third'

module TripleParser

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
      t = TripleSet.new('?location omgeo:nearby(?Latitude, ?Longitude, "5km")')
      assert_equal('var', t.subject.type)
      assert_equal('location', t.subject.value)
      assert_equal('function', t.predicate.type)
      assert_equal('omgeo:nearby', t.predicate.value)
      arguments = [Third.new('?Latitude'), Third.new('?Longitude'), Third.new('"5km"')]
      assert_equal(arguments, t.predicate.arguments)
      assert_nil(t.object)
    end

    def test_with_rdf
      t = TripleSet.new('<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://purl.org/NET/c4dm/event.owl#Event>.')
      assert_equal('<http://www.bbc.co.uk/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id>', t.subject)
      assert_equal('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>', t.predicate)
      assert_equal('<http://purl.org/NET/c4dm/event.owl#Event>', t.object)    
    end

    def test_simple_date_time
      t = TripleSet.new("id:0237eb08-e4a5-463c-baaa-5a28f2b63707 owl:timeline:beginsAtDateTime xml:date_time:'2010-02-15T12:00:00Z'")
      assert_equal('owl:timeline', t.predicate.type)
      assert_equal('xml:date_time', t.object.type)
      assert_equal('2010-02-15T12:00:00Z', t.object.value)
    end

    def test_location
      t = TripleSet.new('resource:United_Kingdom geo-pos:lat ?Latitude ')

      assert_equal('resource:United_Kingdom', t.subject)
      assert_equal('geo-pos:lat', t.predicate)
      assert_equal('?Latitude', t.object)  
    end

    def test_bracketed_url_style_location
      t = TripleSet.new('<http://dbpedia.org/resource/United_Kingdom> geo-pos:lat ?Latitude .')

      assert_equal('<http://dbpedia.org/resource/United_Kingdom>', t.subject)
      assert_equal('geo-pos:lat', t.predicate)
      assert_equal('?Latitude', t.object)  
    end

    def test_bracketed_url_style_function
      t = TripleSet.new('?location omgeo:nearby(?Latitude ?Longitude "5km") .')
      assert_equal('var', t.subject.type)
      assert_equal('location', t.subject.value)
      assert_equal('function', t.predicate.type)
      assert_equal('omgeo:nearby', t.predicate.value)
      arguments = [Third.new('?Latitude'), Third.new('?Longitude'), Third.new('"5km"')]
      assert_equal(arguments, t.predicate.arguments)
      assert_nil(t.object)
    end

    private
    def triple_set(input = nil)
      input ||= @parts
      TripleSet.new(input.join(" "))
    end
  end
end
