
module TripleParser
  class ToRdf
    
    def initialize(third)
      @third = third
    end
    
    def to_s
      get_output.to_s
    end
    
    protected
    def get_output
      if third_type
        pass_to_type_method
      else
        unknown
      end
    end
    
    def third_type
      @third_type ||= @third.type.to_sym if @third.type
    end    
    
    def pass_to_type_method
      if owl_pattern =~ third_type
        owl
      elsif xml_schema_pattern =~ third_type
        xml_schema
      elsif  self.class.instance_methods.include?(third_type)
        send(third_type)
      else
        unknown_type
      end
    end
    
    def owl_pattern
      /owl\:(.*)/
    end
    
    def owl
      owl_type = owl_pattern.match(third_type)[1]
      "<http://purl.org/NET/c4dm/#{owl_type}.owl##{@third.value}>"
    end
    
    def xml_schema_pattern
      /xml\:(.*)/
    end
    
    def xml_schema
      xml_type = xml_schema_pattern.match(third_type)[1]
      %Q{"#{@third.value}"^^<http://www.w3.org/2001/XMLSchema##{camelcase(xml_type)}>}
    end
    
    def unknown
      @third
    end
    
    def unknown_type
      "#{third_type}:#{@third.value}"
    end
    
    def id
      "<http://www.bbc.co.uk/things/#{@third.value}#id>"
    end
    
    def domain
      "<http://www.bbc.co.uk/ontologies/domain/name>"
    end
    
    def resource
      "<http://dbpedia.org/resource/#{@third.value}>"
    end
    
    def ontology
      "<http://data.press.net/ontology/tag/#{@third.value}>"
    end
    
    def function
      arguments = @third.arguments.collect{|a| self.class.new(a)}
      "#{@third.value}(#{arguments.join(', ')})"
    end
    
    def var
      "?#{@third.value}"
    end
    
    def camelcase(text)
      while underscore_pos = text.index(/_[a-z]/)
        letter_after_pos = underscore_pos + 1
        letter_after = text[letter_after_pos, 1]
        text[underscore_pos..letter_after_pos] = letter_after.upcase
      end
      return text
    end
    
  end
end
