require "poslavu/version"

require "poslavu/row"
require "poslavu/client"
require "poslavu/query_scope"

module POSLavu
end

# Add some aliases so as to not be picky about capitalization
Object.const_set(:POSlavu, POSLavu)
Object.const_set(:Poslavu, POSLavu)