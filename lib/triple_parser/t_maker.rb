module TripleParser
  class TMaker
    require_relative 'third'
    require_relative 'bracketed_url_splitter'
    require_relative 'colon_separated_splitter'
    require_relative 'variable_splitter'
    require_relative 'unspecified_splitter'
    
    attr_accessor :arguments, :rdf_style, :url
    
    def self.brew(*args)
      t_maker = new(*args)
      t_maker.third
    end

    def initialize(*args)
      @string = args.first
    end
    
    def third
      begin
        Third.new(
          @string,
          :type => split_text.type,
          :value => split_text.value,
          :url => split_text.url,
          :rdf_style => split_text.rdf_style,
          :arguments => split_text.arguments
        )
      rescue
        Third.new(@string, :rdf_style => 'unknown')
      end
    end

    def split_text
      @split_text ||= get_split_text
    end

    private
    def get_split_text
      splitters.each do |splitter|
        if splitter.can_split?(@string)
          split_text = splitter.new(@string)
          return split_text
        end
      end
      raise "Unable to get parts for third from: '#{@string}'"
    end
  
    def splitters
      [BracketedUrlSplitter, ColonSeparatedSplitter, VariableSplitter, UnspecifiedSplitter]
    end
  

  end
end
