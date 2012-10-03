require "faraday"
require "nokogiri"

class POSLavu::Client
  class Error < RuntimeError; end
  
  URL = "https://admin.poslavu.com/cp/reqserv/"
  
  def initialize(dataname, token, key)
    @parameters = {
      'dataname' => dataname,
      'token' => token,
      'key' => key
    }
  end
  
  def dataname
    @parameters['dataname']
  end
  
  #:nodoc
  def inspect
    "#<POSLavu::Client dataname=#{@parameters['dataname'].inspect}>"
  end
  
  def table(table)
    POSLavu::QueryScope.new(self, table)
  end
  
  # Invokes a command, accepting a +parameters+ hash, and returning an array of
  # POSLavu::Row objects.
  def invoke(command, parameters = {})
    final_parameters = @parameters.merge(parameters).merge('cmd' => command)

    response = connection.post URL, final_parameters

    fragment = Nokogiri::XML.fragment(response.body)
    elements = fragment.children.select(&:element?)   # .element_children doesn't work
    
    if elements.empty?
      if fragment.to_s.strip.empty?
        # did we actually get no data?
        return []
      else
        # this is apparently how errors are signalled
        raise Error, fragment.to_s
      end
    else
      # assume all the elements are <row>s, and let Row explode if we're wrong
      elements.map { |element|
        POSLavu::Row.from_nokogiri(element)
      }
    end
    
  rescue Faraday::Error::ClientError
    raise Error, $!.to_s
  end

  protected
  def connection
    @connection ||= Faraday.new(:url => URL) { |faraday|
      faraday.request :url_encoded
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    }.tap { |connection|
      connection.headers[:user_agent] = "POSLavu Ruby #{POSLavu::VERSION}"
    }
  end
end
