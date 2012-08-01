module TripleParser
  class Third < String
    attr_accessor :arguments, :rdf_style, :url

    def initialize(*args)
      super
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

    private
    def get_parts
      if bracketed_url_pattern =~ self
        get_parts_for_bracketed_url

      elsif function_pattern =~ self
        get_parts_for_function

      elsif include?(':')
        get_parts_for_type_value_pair

      elsif /^\?/ =~ self
        get_complex_type_variable
        
      elsif constant_text_pattern =~ self
        get_constant
        
      elsif modifier_pattern =~ self
        get_modifier
        
      else
        get_parts_for_simple_string
      end
    end
    
    def modifier_pattern
      /^([a-z]+(_[a-z]+)*)$/
    end
    
    def get_modifier
      simple_rdf!
      modifier = self.gsub(/_is/, "").gsub(/has_/, "")
      {:type => modifier}
    end
    
    def constant_text_pattern
      /^[A-Z][a-z][A-Za-z]*$/
    end
    
    def get_constant
      simple_rdf!
      {:type => underscore(self)}
    end

    def function_pattern
      /^[\w_:]+\(.+\)/
    end

    def get_parts_for_function
      simple_rdf!
      opening_bracket = index('(')
      closing_bracket = index(')')
      name = self[0, opening_bracket]
      rest = self[opening_bracket + 1..closing_bracket - 1].split(/[\,\s]+/)
      @arguments = rest.collect{|r| self.class.new(r)}
      {:type => 'function', :value => name}
    end

    def get_parts_for_type_value_pair
      simple_rdf!
      i = index(':')
      before_colon = self[0, (i)]
      after_colon = self[i + 1..length]
      {:type => before_colon, :value => remove_bracketing_quotes(after_colon)}
    end
    
    def remove_bracketing_quotes(text)
      if /^'.+'$/ =~ text || /^".+"$/ =~ text
        return text.gsub(/^['"]/, "").gsub(/['"]$/, "")
      else
        return text
      end
    end

    def get_parts_for_simple_string
      unknown_rdf!
      {}
    end

    def bracketed_url_pattern
      /\<http\:\/\/[\S]+\>/
    end

    def get_parts_for_bracketed_url
      bracketed_url_rdf!
      {
        :url => get_url,
        :type => type_from_bracketed_url,
        :value => get_value_from_bracketed_url
      }
    end

    def get_complex_type_variable
      bracketed_url_rdf!
      text_after_question_mark = self[1..length]
      {:type => 'var', :value => text_after_question_mark}
    end

    def get_url
      url_pattern = /http\:\/\/[\w\-\.]+\.[a-zA-Z]{2,7}(?:\/[\w\-\._]+)*/
      match(url_pattern)[0]
    end
    
    def type_from_bracketed_url
      @type_from_bracket_url ||= get_type_from_bracketed_url
    end

    def get_type_from_bracketed_url
      after_hash_pattern = /\#([a-zA-Z]+)/ 
      resource_url_pattern = /(#{resource_identifiers.join('|')})\/[a-zA-Z_]+\>/
      type_match = match(after_hash_pattern) || match(resource_url_pattern) || match(last_element_of_url_pattern)
      if type_match
        type = type_match[1]
        underscore(type)
      end
    end
    
    def last_element_of_url_pattern 
      /\/([a-zA-Z_]+)\>/
    end

    def get_value_from_bracketed_url
      if type_from_bracketed_url == 'id'
        text_before_hash_pattern = /([\w\-\._]*)\#/
        return match(text_before_hash_pattern)[1]
      end
      if resource_identifiers.include? type_from_bracketed_url
        return match(last_element_of_url_pattern)[1]
      end
      value_match = match(/^\"(.*)\"/)
      if value_match
        value_match[1] 
      end
    end

    def resource_identifiers
      %w{resource domain}
    end
    
    def simple_rdf!
      @rdf_style = 'simple'
    end

    def bracketed_url_rdf!
      @rdf_style = 'bracketed_url'
    end

    def unknown_rdf!
      @rdf_style = 'unknown'
    end

    def underscore(text)
      while letter_before_capital = text.index(/[a-z][A-Z]/)
        text.insert(letter_before_capital + 1, '_')
      end
      text.downcase
    end

  end
end
