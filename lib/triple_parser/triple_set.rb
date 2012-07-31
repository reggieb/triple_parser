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
      @object ||= parts[2].empty? ? nil : parts[2]
    end

    private
    def get_parts
      match = pattern_to_split_triple.match(@triple)
      [1, 2, 3].collect{|i| Third.new(match[i])}
    end

    def pattern_to_split_triple
      if triple_is_rdf?
        pattern_to_split_bracketed_url_rdf
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

    def pattern_to_split_bracketed_url_rdf
      standard_rdf_element_or_text = '(?:<.*>|[\w\?\-:]+)'
      optional_input = '(?:\".+\"\^\^)?'

      rdf_element = ['(', optional_input, standard_rdf_element_or_text, ')']

      spaces = '\s*'

      Regexp.new([rdf_element, spaces, rdf_element, spaces, rdf_element].flatten.join)
    end

    def pattern_to_split_simple_triple
      basic_text_input = '[\w\:-]*'
      optional_text_with_string = %q{(?:["'][\w\s\-:]*["'])?}
      optional_function_arguments = '(?:\(.*\))?'

      text = ['(', basic_text_input, optional_text_with_string, optional_function_arguments, ')']

      spaces = '\s*'

      Regexp.new([text, spaces, text, spaces, text].flatten.join)
    end
  end
end
