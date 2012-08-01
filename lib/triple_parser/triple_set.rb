module TripleParser
  class TripleSet
    require_relative 'third'

    def initialize(triple)
      @triple = triple
    end

    def parts
      @parts ||= get_parts
    end

    def subject
      @subject ||= parts[0]    
    end

    def predicate
      @predicate ||= parts[1]
    end

    def object
      @object ||= (!parts[2] || parts[2].empty?) ? nil : parts[2]
    end

    private
    def get_parts
      pattern_to_split_triple
      match = pattern_to_split_triple.match(@triple)
      matches = [1, 2, 3].collect{|i| match[i] if i != @skip_triple_part}.compact
      matches.collect{|m| Third.new(m)}
    end

    def pattern_to_split_triple
      if triple_is_rdf?
        pattern_to_split_bracketed_url_rdf
      elsif triple_if_function?
        @skip_triple_part = 3
        pattern_to_split_function
      else
        pattern_to_split_simple_triple
      end
    end

    def triple_is_rdf?
      @triple.index(rdf_pattern)
    end

    def rdf_pattern
      /\<.+\>[\.\s]/
    end
    
    def triple_if_function?
      function_pattern =~ @triple
    end
    
    def function_pattern

    Regexp.new([
      start_with_possible_white_space_pattern,
      start_variable_or_bracketed_url_pattern,
      receiving_variable_or_bracketed_url_pattern,
      function_name_pattern,
      function_arguments_pattern,
      closing_white_space_or_period_pattern,
    ].join)
  
    end

    def pattern_to_split_bracketed_url_rdf
      standard_rdf_element_or_text_pattern
      
      optional_input = '(?:\".+\"\^\^)?'

      rdf_element = ['(', optional_input, standard_rdf_element_or_text_pattern, ')']

      Regexp.new([rdf_element, spaces, rdf_element, spaces, rdf_element].flatten.join)
    end

    def pattern_to_split_simple_triple
      
      optional_input = %q{(?:["'][\w\s-:]*["'])?}

      text = ['(', basic_text_pattern, optional_input, ')']

      Regexp.new([text, spaces, text, spaces, text].flatten.join)
    end
    
    def pattern_to_split_function
      
      receiving_element_pattern = '[\w?:\/_\-#<>\.]+'

      Regexp.new(
        [
          '(', 
            receiving_element_pattern,
          ')', 
          spaces, 
          '(', 
            function_name_pattern, 
            function_arguments_pattern, 
          ')'
        ].join
      )
      
    end
    
    def spaces
      '\s+'
    end
    
    def start_with_possible_white_space_pattern
      '^\s*'
    end
    
    def start_variable_or_bracketed_url_pattern
      '(\?|<http:\/\/)'
    end
    
    def receiving_variable_or_bracketed_url_pattern
      '[\w\/\-_#\.]+>?\s+'
    end
    
    def basic_text_pattern
      '\??[\w_\-:]+'
    end
    
    def function_name_pattern
      '[\w_\-:]+'
    end
    
    def function_arguments_pattern
      %q{\(([\w_\?:"']+[\s\,]*)+\)}
    end
    
    def closing_white_space_or_period_pattern
      '[\s\.]*$'
    end
    
    def standard_rdf_element_or_text_pattern
      '(?:<.*>|[\w\?\-:]+)'
    end
      
  end
end
