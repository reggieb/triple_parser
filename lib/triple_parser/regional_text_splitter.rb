module TripleParser
  
  class RegionalTextSplitter < Splitter
    
    def self.can_split?(string)
      quoted_text_ampersand_and_language_identifier =~ string
    end
    
    def rdf_style
      'regional_text'
    end
    
    private
    def self.quoted_text_ampersand_and_language_identifier
      /('.*'|".*")\@[\w\-_]+/
    end
    
    def get_parts
      {
        :type => "text:#{region}",
        :value => text
      }
    end
    
    def region
      after_ampersand
    end
    
    def text
      before_ampersand.gsub(/^['"]/, '').gsub(/['"]$/, '')
    end
    
    def after_ampersand
      split(/@/).last
    end
    
    def before_ampersand
      split(/@/).first
    end
  end
end
