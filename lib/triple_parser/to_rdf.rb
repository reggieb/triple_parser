
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
      @third_type ||= @third.type if @third.type
    end    
    
    def pass_to_type_method
      if type_if_known_colon_pair?
        send(colon_prefix)
        
      elsif method_exists_for?(third_type)
        send(third_type)
        
      else
        unknown_type
      end
    end
    
    def type_if_known_colon_pair?
      if colon_pair_pattern =~ third_type
        method_exists_for?(colon_prefix)
      end
    end
    
    def method_exists_for?(name)
      self.class.instance_methods.include?(name.to_sym)
    end
    
    # prefix:suffix
    def colon_pair_pattern
      /([a-zA-Z\-\_]+)\:([a-zA-Z\-\_]+)/
    end
    
     def colon_match
      @colon_match ||= colon_pair_pattern.match(third_type)
    end    
    
    def colon_prefix
      @colon_prefix ||= colon_match[1]
    end
    
    def colon_suffix
      @colon_suffix ||= colon_match[2]
    end 

    def owl
      "<http://purl.org/NET/c4dm/#{colon_suffix}.owl##{@third.value}>"
    end

    
    def xml
      %Q{"#{@third.value}"^^<http://www.w3.org/2001/XMLSchema##{camelcase(colon_suffix)}>}
    end
    
    def dc
      "<http://purl.org/dc/#{colon_suffix}/#{@third.value}>"
    end
    
    def text
      %Q{"#{@third.value}"@#{colon_suffix}}
    end
    
    def unknown
      @third
    end
    
    def unknown_type
      "#{third_type}:#{@third.value}"
    end
    
    def id
      "<http://#{Settings.application_domain}/things/#{@third.value}#id>"
    end
    
    def domain
      "<http://#{Settings.application_domain}/ontologies/domain/name>"
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
    
    def rdf
      "<http://www.w3.org/1999/02/22-rdf-syntax-ns##{@third.value}>"
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
