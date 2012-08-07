require 'rake/gempackagetask'

Gem::Specification.new do |s|
  s.name = 'triple_parser'
  s.version = '0.1.1'
  s.authors = ['Rob Nichols']
  s.date = %q{2012-08-07}
  s.description = "Triple Parser - Parses RDF triples and converts them into standard format"
  s.summary = s.description
  s.email = 'rob@undervale.co.uk'
  s.homepage = 'https://github.com/reggieb/triple_parser'
  s.files = ['README', FileList['lib/**/*.rb']].flatten
end