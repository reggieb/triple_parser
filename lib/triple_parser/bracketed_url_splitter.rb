module TripleParser
  
  require_relative 'splitter'
  
  class BracketedUrlSplitter < Splitter

    def self.can_split?(string)
      bracketed_url_pattern =~ string
    end
    
    def rdf_style
      'bracketed_url'
    end
    
    private
    def self.bracketed_url_pattern
      /\<http\:\/\/[\S]+\>/
    end
    
    def get_parts
      type_value_from_bracketed_url.merge(
        :url => get_url
      )
    end
    
    def get_url
      url_pattern = /http\:\/\/[\w\-\.]+\.[a-zA-Z]{2,7}(?:\/[\w\-\._]+)*/
      match(url_pattern)[0]
    end
    
    
    def type_value_from_bracketed_url
      if text_after_hash_pattern =~ self
        type_value_from_text_after_hash_url
        
      elsif resource_url_pattern =~ self
        type_value_for_resource
        
      elsif ontology_url_pattern =~ self
        type_value_for_ontology
        
      elsif dc_terms_pattern =~ self
        type_value_for_dc_terms
        
      elsif asset_pattern =~ self
        type_value_for_asset
        
      else
        {}
        
      end
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
        :type => "xml:#{underscore(after_hash)}",
        :value => match(xml_data_pattern)[1]
      }
    end
    
    def owl_pattern
      /\.owl#/
    end
    
    def type_value_for_owl
      type = match(text_before_hash_pattern)[1]
      {
        :type => "owl:#{type.gsub(/\.owl/, "")}",
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
    
    def ontology_url_pattern
      /data\.press\.net\/ontology\/(?:\w+\/)+(\w+)/
    end
    
    def type_value_for_ontology
      {
        :type => 'ontology',
        :value => match(ontology_url_pattern)[1]
      }
    end  
    
    def dc_terms_pattern
      /\/dc\/terms\/([a-zA-Z_]+)/
    end
    
    def type_value_for_dc_terms
      {
        :type => 'dc:terms',
        :value => match(dc_terms_pattern)[1]
      }
    end
    
    def asset_pattern
      /\/ontologies\/asset\/([a-zA-Z_]+)/
    end
    
    def type_value_for_asset
      {
        :type => 'asset',
        :value => match(asset_pattern)[1]
      }      
    end
    
    def last_element_of_url_pattern 
      /\/([a-zA-Z_]+)\>/
    end
    
    def resource_url_pattern 
      /(#{resource_identifiers.join('|')})\/[a-zA-Z_]+\>/
    end
   
  end
  
end
