$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser/third'

module TripleParser

  class ThirdTest < Test::Unit::TestCase

    def setup
      @value = '9108fe02-0bbb-4ed9-890f-b454877ce12c'
      @type = 'id'
      @input = "#{@type}:#{@value}"
      @third = Third.new(@input)
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
      third = Third.new("date_time:'2010-02-17T12:00:00Z'")
      assert_equal('date_time', third.type)
      assert_equal('2010-02-17T12:00:00Z', third.value)
      assert_equal('simple', third.rdf_style)
    end

    def test_function
      third = Third.new('omgeo:nearby(?Latitude, ?Longitude, "5km")')
      assert_equal('function', third.type)
      assert_equal('omgeo:nearby', third.value)
      arguments = [Third.new('?Latitude'), Third.new('?Longitude'), Third.new('"5km"')]
      assert_equal(arguments, third.arguments)
      assert_equal('simple', third.rdf_style)
    end

    def test_object_type
      third = Third.new('SomeType')
      assert_equal('some_type', third.type)
      assert_nil(third.value, "Value should be nil")
      assert_equal('simple', third.rdf_style)
      assert_nil(third.url, "url should be nil")   
    end

    def test_lowercase_string
      simple_text = "something"
      third = Third.new(simple_text)
      assert_equal(simple_text, third.type)
      assert_nil(third.value, "Value should return nil")
      assert_equal('simple', third.rdf_style)
    end

    def test_modifier
      simple_text = "something_is"
      third = Third.new(simple_text)
      assert_equal('something', third.type)
      assert_nil(third.value, "Value should return nil")
      assert_equal('simple', third.rdf_style)
    end

    def test_with_unknown_input
      unknown = "5admName"
      third = Third.new(unknown)
      assert_nil(third.type, "Type should return nil")
      assert_nil(third.value, "Value should return nil")
      assert_equal('unknown', third.rdf_style)
    end

    def test_bracketed_url
      url = 'http://www.bbc.co.uk/ontologies/domain/name'
      bracketed_url = "<#{url}>"
      third = Third.new(bracketed_url)
      assert_equal('domain', third.type)
      assert_equal('name', third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end

    def test_bracketed_pair_with_type
      url = 'http://purl.org/NET/c4dm/event.owl'
      type = 'someType'
      bracketed_url = "<#{url}##{type}>"
      third = Third.new(bracketed_url)
      assert_equal('some_type', third.type)
      assert_nil(third.value, "Value should be nil")
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end

    def test_bracketed_pair_with_single_word_type
      url = 'http://purl.org/NET/c4dm/event.owl'
      type = 'Some'
      bracketed_url = "<#{url}##{type}>"
      third = Third.new(bracketed_url)
      assert_equal('some', third.type)
    end

    def test_bracketed_pair_with_type_and_value
      url = 'http://www.w3.org/2001/XMLSchema'
      type = 'dateTime'
      value = '2010-02-15T12:00:00Z'
      bracketed_url = "\"#{value}\"^^<#{url}##{type}>"
      third = Third.new(bracketed_url)
      assert_equal('date_time', third.type)
      assert_equal(value, third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end

    def test_bracketed_pair_with_id_and_value
      type = 'id'
      value = '9108fe02-0bbb-4ed9-890f-b454877ce12c'
      url = "http://www.bbc.co.uk/things/#{value}"
      bracketed_url = "<#{url}##{type}>"
      third = Third.new(bracketed_url)
      assert_equal(type, third.type)
      assert_equal(value, third.value)
      assert_equal('bracketed_url', third.rdf_style)
      assert_equal(url, third.url)
    end

    def test_variable_of_complex_type
      variable = '?this'
      third = Third.new(variable)
      assert_equal('var', third.type)
      assert_equal('this', third.value)
      assert_equal('bracketed_url', third.rdf_style)
    end

    def test_resource_from_complex_type
      bracketed_url = "<http://dbpedia.org/resource/United_Kingdom>"
      third = Third.new(bracketed_url)
      assert_equal('resource', third.type)
      assert_equal('United_Kingdom', third.value)
      assert_equal('bracketed_url', third.rdf_style)
    end

    def test_latitude
      text = 'geo-pos:lat'
      third = Third.new(text)
      assert_equal('geo-pos', third.type)
      assert_equal('lat', third.value)
      assert_equal('simple', third.rdf_style)
    end
  end

end