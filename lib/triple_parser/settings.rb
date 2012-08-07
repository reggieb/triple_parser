
module TripleParser
  module Settings
    def self.application_url
      @@application_url ||= 'en.wikipedia.org/wiki/Triplestore'
    end
    
    def self.application_url=(url)
      @@application_url = url
    end
  end
end
