$:.unshift File.join(File.dirname(__FILE__),'lib')

require 'rubygems'
require 'sinatra'
require 'erb'
require_relative 'lib/triple_parser'

TripleParser::Settings.application_domain = 'undervale.co.uk'

get '/' do
  erb :converter
end

post '/' do
  @triples = params['triples'].strip
  @output = TripleParser.to_rdf(@triples)
  erb :converter
end

