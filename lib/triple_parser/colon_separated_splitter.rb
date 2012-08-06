module TripleParser
  
  require_relative 'splitter'
  
  class ColonSeparatedSplitter < Splitter
    
    def self.can_split?(string)
      colon_separated_rdf_pattern =~ string
    end
    
    def rdf_style
      'colon_separated'
    end
    
    private
    def self.colon_separated_rdf_pattern
      colon_pair = '[a-z\-]+:[\w-]+' # this:example
      colon_followed_by_quoted_string = %q{:(['"].+['"]|\w+)} # :'this example'
      function = '\(.+\)' # (this, example)
      colon_separated_text = "#{colon_pair}(#{colon_followed_by_quoted_string}|#{function})?" # this:example or this:example:'with string' or this:function(example)
      
      Regexp.new(colon_separated_text)
    end
    
    def get_parts
      if function_pattern =~ self
        get_parts_for_function

      elsif ontologies.include?(self)
        get_ontology
        
      elsif double_colon_first_elements.include?(before_colon)
        get_double_colon_entry
        
      elsif include?(':')
        get_parts_for_type_value_pair  
        
      else
         raise "Unable to get parts from '#{self}'"
      end
    end
    
        def function_pattern
      /^[\w_:]+\(.+\)/
    end

    def get_parts_for_function
      opening_bracket = index('(')
      closing_bracket = index(')')
      name = self[0, opening_bracket]
      @arguments = self[opening_bracket + 1..closing_bracket - 1].split(/[\,\s]+/)
      @arguments = @arguments.collect!{|r| TMaker.brew(r)}
      {:type => 'function', :value => name}
    end

    def get_parts_for_type_value_pair
      {:type => before_colon, :value => after_colon}
    end
    
    def before_colon
      @before_colon ||= self[0, (index(':'))] if include?(':')
    end
      
    def after_colon
      @after_colon ||= self[index(':') + 1..length] if include?(':')   
    end 
    
    def remove_bracketing_quotes(text)
      if /^'.+'$/ =~ text || /^".+"$/ =~ text
        return text.gsub(/^['"]/, "").gsub(/['"]$/, "")
      else
        return text
      end
    end
    
    def double_colon_first_elements
      %w{xml owl}
    end
    
    def get_double_colon_entry
      elements = split(':')
      text_after_second_colon = elements[2..elements.length].join(':')
      {
        :type => "#{elements[0]}:#{elements[1]}",
        :value => remove_bracketing_quotes(text_after_second_colon)
      }
    end
    
    def get_ontology
      {:type => 'ontology', :value => self}
    end

  end
  
end
