
module TripleParser
  class Splitter < String
    
    attr_accessor :parts, :arguments, :rdf_style, :url
    
    def self.can_split?(string)
      raise "Need to define test to determine if string can be converted using this class"
    end
    
    def parts
      @parts ||= get_parts
    end

    def type
      parts[:type]
    end

    def value
      parts[:value]
    end

    def url
      parts[:url]
    end
    
    def rdf_style
      raise "Need to define string that identifies rdf stype"
    end
    
    private
    def get_parts
      raise "Need to define how to split text input into seperate parts"
    end
    
    def underscore(text)
      while letter_before_capital = text.index(/[a-z][A-Z]/)
        text.insert(letter_before_capital + 1, '_')
      end
      text.downcase
    end
    
    def resource_identifiers
      %w{resource domain}
    end
    
    def ontologies
      %w{about mentions}
    end    
    
  end
end
