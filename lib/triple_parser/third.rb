module TripleParser
  class Third < String
    attr_accessor :type, :value, :arguments, :rdf_style, :url
    def initialize(string, args = {})
      @type = args[:type]
      @value = args[:value]
      @arguments = args[:arguments]
      @rdf_style = args[:rdf_style]
      @url = args[:url]
      super(string)
    end
    
  end
end
