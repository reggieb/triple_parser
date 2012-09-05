module TripleParser
  class TripleSet
    require_relative 't_maker'

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
      match = pattern_to_split_triple.match(@triple)
      matches = [1, 2, 3].collect{|i| match[i] if i != @skip_triple_part}.compact
      matches.collect{|m| TMaker.brew(m)}
    end

    def pattern_to_split_triple
      if triple_is_function?
        @skip_triple_part = 3
        pattern_to_split_function
      else
        triple_spitting_pattern
      end
    end

    def triple_is_function?
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
    
    def triple_spitting_pattern
      triple_containing_bracketed_data = %q{<[^>]*>}
      triple_containing_single_quoted_text = %q{\S*\'.*\'\S*}
      triple_containing_double_quoted_text = %q{\S*\".*\"\S*}
      text_not_split_by_spaces = '\S*'
      triple = [triple_containing_bracketed_data, triple_containing_single_quoted_text, triple_containing_double_quoted_text, text_not_split_by_spaces].join('|')
      spaced_triples = Array.new(3, "(#{triple})").join('\s+')
      line_end = '[\s\.]*$'
      Regexp.new(spaced_triples + line_end)
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
