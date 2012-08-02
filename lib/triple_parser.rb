require_relative 'triple_parser/third'
require_relative 'triple_parser/triple_set'
require_relative 'triple_parser/to_rdf'


module TripleParser
  def self.input(text)
    @text = text
  end
  
  def self.triples
    @triples = Array.new
    @text.each_line do |triple| 
      next if /^\s*$/ =~ triple
      @triples << TripleSet.new(triple)
    end
    return @triples
  end
  
  def self.to_rdf(text)
    @text = text
    output = triples.collect do |t|
      [
        get_rdf_for(t.subject),
        get_rdf_for(t.predicate),
        get_rdf_for(t.object)
      ].join(' ') + " ."
    end 
    return output
  end
  
  def self.get_rdf_for(third)
    ToRdf.new(third).to_s if third
  end
end
