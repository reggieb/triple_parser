require_relative 'triple_parser/t_maker'
require_relative 'triple_parser/triple_set'
require_relative 'triple_parser/to_rdf'
require_relative 'triple_parser/settings'


module TripleParser
  def self.input(new_input)
    @input = new_input
  end
  
  def self.triples
    @triples = Array.new
    case @input.class.to_s
      when 'String'
        @input.each_line do |triple| 
          next if /^\s*$/ =~ triple
          @triples << TripleSet.new(triple)
        end
      when 'Array'
        @input.compact.each do |triple|
          @triples << TripleSet.new(triple)
        end
    else
      raise "Input format not recognised"
    end
    
    return @triples
  end
  
  def self.to_rdf(input)
    @input = input
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
