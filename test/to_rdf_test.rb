$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'triple_parser/to_rdf'
require 'triple_parser/third'

module TripleParser

  class ToRdfTest < Test::Unit::TestCase
    
    def test_unknown_text
      unknown = "5admName"
      third = Third.new(unknown)
      assert_rdf_output(third, unknown)
    end
    
    def test_unknown_type
      url = 'http://purl.org/NET/c4dm/event.owl'
      type = 'someType'
      triple = "<#{url}##{type}>"
      assert_bracketed_url_type_returns_self(triple)
    end
    
    def test_date_time
      triple = '"2010-02-15T12:00:00Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>'
      assert_bracketed_url_type_returns_self(triple)
    end
    
    
    
    def assert_bracketed_url_type_returns_self(triple)
      third = Third.new(triple)
      assert_rdf_output(third, triple)
    end
    
    def assert_rdf_output(third, expected_output)
      to_rdf = ToRdf.new(third)
      assert_equal(expected_output, to_rdf.to_s)
    end
    
  end

end
