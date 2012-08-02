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

      elsif variable_pattern =~ self
        get_variable
        
      elsif ontologies.include?(self)
        get_ontology
        
      else
        get_parts_for_simple_string
      end
    end
    
    def variable_pattern
      /^\?/
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
    
    def get_ontology
      simple_rdf!
      {:type => 'ontology', :value => self}
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
      
      type_value_from_bracketed_url.merge(
        :url => get_url
      )
    end

    def get_variable
      bracketed_url_rdf!
      text_after_question_mark = self[1..length]
      {:type => 'var', :value => text_after_question_mark}
    end

    def get_url
      url_pattern = /http\:\/\/[\w\-\.]+\.[a-zA-Z]{2,7}(?:\/[\w\-\._]+)*/
      match(url_pattern)[0]
    end
    
    
    def last_element_of_url_pattern 
      /\/([a-zA-Z_]+)\>/
    end
    
    def type_value_from_bracketed_url
      if text_after_hash_pattern =~ self
        type_value_from_text_after_hash_url
        
      elsif resource_url_pattern =~ self
        type_value_for_resource
        
      elsif ontology_url_pattern =~ self
        type_value_for_ontology
        
        
      else
        {}
        
      end
    end

    def ontology_url_pattern
      /data\.press\.net\/ontology\/(?:\w+\/)+(\w+)/
    end
    
    def type_value_for_ontology
      {
        :type => 'ontology',
        :value => match(ontology_url_pattern)[1]
      }
    end

    def text_after_hash_pattern
      /\#([a-zA-Z]+)/
    end
    
    def after_hash 
      @after_hash ||= match(text_after_hash_pattern)[1] if match(text_after_hash_pattern)
    end
   
    def type_value_from_text_after_hash_url
      
      
      if after_hash == 'id'
        type_value_for_id_after_hash

      elsif xml_data_pattern =~ self
        type_value_for_xml_schema
        
      elsif rdf_url_pattern =~ self
        type_value_for_rdf
        
      elsif owl_pattern =~ self
        type_value_for_owl
        
      else
        {}
      end
    end
    
    def xml_data_pattern
      /["'](.+)["']\^{2}\<http/
    end
    
    def type_value_for_xml_schema
      {
        :type => underscore(after_hash),
        :value => match(xml_data_pattern)[1]
      }
    end
    
    def owl_pattern
      /\.owl#/
    end
    
    def type_value_for_owl
      {
        :type => match(text_before_hash_pattern)[1].gsub(/\.owl/, '_owl'),
        :value => after_hash
      }      
    end
    
    def rdf_url_pattern
      /rdf\-syntax\-ns/
    end
    
    def type_value_for_rdf
      {
        :type => 'rdf',
        :value => after_hash
      }     
    end
    
    def type_value_for_id_after_hash
      {
        :type => 'id',
        :value => match(text_before_hash_pattern)[1]
      }
    end
    
    def text_before_hash_pattern
      /([\w\-\._]*)\#/
    end
    
    def type_value_for_resource
      {
        :type => match(resource_url_pattern)[1],
        :value => match(last_element_of_url_pattern)[1]
      }
    end
    
    def resource_url_pattern 
      /(#{resource_identifiers.join('|')})\/[a-zA-Z_]+\>/
    end

    def resource_identifiers
      %w{resource domain}
    end
    
    def ontologies
      %w{about mentions}
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
