module TripleParser
  
  class VariableSplitter < Splitter
    
    def self.can_split?(string)
      any_word_starting_with_question_mark =~ string
    end
    
    def rdf_style
      'variable'
    end
    
    private
    def self.any_word_starting_with_question_mark
      /^\s*\?[A-Za-z][\w\-]*\s*$/
    end
    
    def get_parts
      {
        :type => 'var',
        :value => variable_name
      }
    end
    
    def variable_name
      self[1..length]
    end
    
  end
end
