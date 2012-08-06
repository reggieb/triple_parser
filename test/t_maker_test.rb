$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser/t_maker'

module TripleParser

  class TMakerTest < Test::Unit::TestCase

    def setup
      @value = '9108fe02-0bbb-4ed9-890f-b454877ce12c'
      @type = 'id'
      @input = "#{@type}:#{@value}"
      @third = TMaker.brew(@input)
    end

    def test_third
      assert(@third.kind_of?(String), "third should be a kind of String")
    end

    def test_type
      assert_equal(@type, @third.type)
    end

    def test_value
      assert_equal(@value, @third.value)
    end

    def test_url
      assert_nil(@third.url, "url should be nil if none in input")
    end

    def test_date_time
      third = TMaker.brew("xml:date_time:'2010-02-17T12:00:00Z'")
      assert_equal('xml:date_time', third.type)
      assert_equal('2010-02-17T12:00:00Z', third.value)
      assert_equal('colon_separated', third.rdf_style)
    end
    
     def test_string
      third = TMaker.brew("xml:string:'This is a string'")
      assert_equal('xml:string', third.type)
      assert_equal('This is a string', third.value)
      assert_equal('colon_separated', third.rdf_style)
    end
    
     def test_function
      third = TMaker.brew('omgeo:nearby(?Latitude, ?Longitude, "5km")')
      assert_equal('function', third.type)
      assert_equal('omgeo:nearby', third.value)
      arguments = [TMaker.brew('?Latitude'), TMaker.brew('?Longitude'), TMaker.brew('"5km"')]
      assert_equal(arguments, third.arguments)
      assert_equal('colon_separated', third.rdf_style)
    end

    def test_with_unknown_input
      unknown = "5admName Haf"
      third = TMaker.brew(unknown)
      assert_nil(third.type, "Type should return nil")
      assert_nil(third.value, "Value should return nil")
      assert_equal('unknown', third.rdf_style)
    end
    
    def test_mentions
      third = TMaker.brew('ontology:mentions')
      assert_equal('ontology', third.type)
      assert_equal('mentions', third.value)
      assert_equal('colon_separated', third.rdf_style)
    end
    
    def test_bracketed_url_mentions
      url = '<http://data.press.net/ontology/tag/mentions>'
      third = TMaker.brew(url)
      assert_equal('ontology', third.type)
      assert_equal('mentions', third.value)
      assert_equal('bracketed_url', third.rdf_style)
    end
    
    def test_about
      third = TMaker.brew('ontology:about')
      assert_equal('ontology', third.type)
      assert_equal('about', third.value)
      assert_equal('colon_separated', third.rdf_style)
    end
    
    def test_bracketed_url_about
      url = '<http://data.press.net/ontology/tag/about>'
      third = TMaker.brew(url)
      assert_equal('ontology', third.type)
      assert_equal('about', third.value)
      assert_equal('bracketed_url', third.rdf_style)
    end

    def test_bracketed_url_domain
      url = 'http://www.bbc.co.uk/ontologies/domain/name'
      bracketed_url = "<#{url}>"
      third = TMaker.brew(bracketed_url)
      assert_equal('domain', third.type)
      assert_equal('name', third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end
    
    def test_owl_event
      text = 'owl:event:Event'
      third = TMaker.brew(text)
      assert_equal('owl:event', third.type)
      assert_equal('Event', third.value)
      assert_equal('colon_separated', third.rdf_style)
    end

    def test_bracketed_pair_with_owl_event
      url = 'http://purl.org/NET/c4dm/event.owl'
      type = 'Event'
      bracketed_url = "<#{url}##{type}>"
      third = TMaker.brew(bracketed_url)
      assert_equal('owl:event', third.type)
      assert_equal('Event', third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end
    
    def test_owl_event_time
      text = 'owl:event:time'
      third = TMaker.brew(text)
      assert_equal('owl:event', third.type)
      assert_equal('time', third.value)
      assert_equal('colon_separated', third.rdf_style)
    end

    def test_bracketed_pair_with_owl_event_time
      url = 'http://purl.org/NET/c4dm/event.owl'
      type = 'time'
      bracketed_url = "<#{url}##{type}>"
      third = TMaker.brew(bracketed_url)
      assert_equal('owl:event', third.type)
      assert_equal('time', third.value)
    end
    
    def test_bracket_pair_with_rdf_syntax
      url = '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'
      third = TMaker.brew(url)
      assert_equal('rdf', third.type)
      assert_equal('type', third.value)
      assert_equal('bracketed_url', third.rdf_style)
    end

    def test_bracketed_pair_with_type_and_value
      url = 'http://www.w3.org/2001/XMLSchema'
      type = 'dateTime'
      value = '2010-02-15T12:00:00Z'
      bracketed_url = "\"#{value}\"^^<#{url}##{type}>"
      third = TMaker.brew(bracketed_url)
      assert_equal('xml:date_time', third.type)
      assert_equal(value, third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end
    
    def test_bracketed_pair_with_text_value_and_period
      url = 'http://www.w3.org/2001/XMLSchema'
      type = 'string'
      value = 'Troops tighten grip on Taliban stronghold'
      bracketed_url = "\"#{value}\"^^<#{url}##{type}>."
      third = TMaker.brew(bracketed_url)
      assert_equal('xml:string', third.type)
      assert_equal(value, third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)     
    end
    
    def test_bracketed_pair_with_id_and_value
      type = 'id'
      value = '9108fe02-0bbb-4ed9-890f-b454877ce12c'
      url = "http://www.bbc.co.uk/things/#{value}"
      bracketed_url = "<#{url}##{type}>"
      third = TMaker.brew(bracketed_url)
      assert_equal(type, third.type)
      assert_equal(value, third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end

    def test_variable
      variable = '?this'
      third = TMaker.brew(variable)
      assert_equal('var', third.type)
      assert_equal('this', third.value)
      assert_equal('variable', third.rdf_style)
    end

    def test_resource_from_complex_type
      bracketed_url = "<http://dbpedia.org/resource/United_Kingdom>"
      third = TMaker.brew(bracketed_url)
      assert_equal('resource', third.type)
      assert_equal('United_Kingdom', third.value)
      assert_equal('bracketed_url', third.rdf_style)
    end

    def test_latitude
      text = 'geo-pos:lat'
      third = TMaker.brew(text)
      assert_equal('geo-pos', third.type)
      assert_equal('lat', third.value)
      assert_equal('colon_separated', third.rdf_style)
    end
  end

end