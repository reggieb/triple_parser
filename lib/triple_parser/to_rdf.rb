
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
    
    def pass_to_type_method
      if self.class.instance_methods.include?(third_type)
        send(third_type)
      else
        unknown_type
      end
    end
    
    def unknown
      @third
    end
    
    def unknown_type
      "<http://purl.org/NET/c4dm/event.owl##{camelcase(@third.type)}>"
    end
    
    def date_time
      %Q{"#{@third.value}"^^<http://www.w3.org/2001/XMLSchema#dateTime>}
    end
    
    def third_type
      @third.type.to_sym if @third.type
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
