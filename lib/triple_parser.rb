require_relative 'triple_parser/third'
require_relative 'triple_parser/triple_set'


module TripleParser
  def self.input(text)
    @text = text
  end
  
  def self.triples
    @triples = Array.new
    @text.each_line{|triple| @triples << TripleSet.new(triple)}
    return @triples
  end
end
