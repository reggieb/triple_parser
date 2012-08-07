
module TripleParser
  module Settings
    def self.application_domain
      @@application_url ||= 'en.wikipedia.org/wiki/Triplestore'
    end
    
    def self.application_domain=(url)
      @@application_url = url
    end
  end
end
