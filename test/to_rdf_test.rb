$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser'

module TripleParser

  class ToRdfTest < Test::Unit::TestCase
    
    def test_unknown_text
      @triple = "5admName"
      assert_triple
    end
    
    def test_unknown_type
      @triple = 'geo-pos:lat'
      assert_triple
    end
    
    def test_id
      @triple = "<http://#{Settings.application_domain}/things/9108fe02-0bbb-4ed9-890f-b454877ce12c#id>"
      assert_triple
    end
    
    def test_event
      @triple = '<http://purl.org/NET/c4dm/event.owl#Event>'
      assert_triple
    end
    
    def test_event_time
      @triple = '<http://purl.org/NET/c4dm/event.owl#time>'
      assert_triple
    end
    
    def test_begins_at_date_time
      @triple = '<http://purl.org/NET/c4dm/timeline.owl#beginsAtDateTime>'
      assert_triple
    end
    
    def test_date_time
      @triple = '"2010-02-15T12:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>'
      assert_triple
    end
    
    def test_text
      @triple = %q{"Troops tighten grip on Taliban stronghold"^^<http://www.w3.org/2001/XMLSchema#string>}
      assert_triple
    end
    
    def test_domain_name
      @triple = "<http://#{Settings.application_domain}/ontologies/domain/name>"
      assert_triple
    end
    
    def test_event_place
      @triple = '<http://purl.org/NET/c4dm/event.owl#place>'
      assert_triple
    end
    
    def test_resource
      @triple = '<http://dbpedia.org/resource/United_Kingdom>'
      assert_triple
    end
    
    def test_ontology
      @triple = '<http://data.press.net/ontology/tag/about>'
      assert_triple
    end
    
    def test_rdf_type
      @triple = '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'
      assert_triple
    end
    
    def test_variable
      @triple = '?MyVariable'
      assert_triple
    end
    
    def test_function
      @triple = 'nearby(?Latitude, ?Longitude, "5km")'
      assert_triple
    end
    
    def test_dc_term
      @triple = '<http://purl.org/dc/terms/title>'
      assert_triple
    end
    
    private
    def assert_triple
      assert_bracketed_url_type_returns_self
    end
    
    def assert_bracketed_url_type_returns_self
      third = TMaker.brew(@triple)
      to_rdf = ToRdf.new(third)
      assert_equal(@triple, to_rdf.to_s)
    end
    
  end

end
