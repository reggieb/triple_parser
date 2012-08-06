module TripleParser
  
  require_relative 'splitter'
  
  class UnspecifiedSplitter < Splitter

    def self.can_split?(string)
      any_word_possibly_hyphenated =~ string
    end
    
    def rdf_style
      'unspecified'
    end
    
    private
    def self.any_word_possibly_hyphenated
      /^\s*[\w\-]*\s*$/
    end
    
    def get_parts
      {}
    end
    
    
  end
  
end
