require "faraday"
require "nokogiri"

# POSLavu::Client communicates with the POSLavu API over HTTPS.
# 
# You must provide a +dataname+, +token+, and +key+ to create a Client.
# From here, you can call Client#invoke to run arbitrary API commands.
#
# Clients don't hold any state except for a Faraday::Connection, which
# may or may not use persistent connections depending on your default
# Faraday adapter.
class POSLavu::Client
  
  # Encapsulates an error thrown by the POSLavu API. All failing API calls
  # via Client#invoke raise a subclass of this exception.
  #
  # See also:
  # * CommandFailedError
  # * CommunicationError
  class Error < RuntimeError; end
  
  # Represents an error returned by the API. POSLavu couldn't even be bothered to
  # use HTTP status codes, so there's nothing machine-readable here. If you need
  # to distinguish various types of errors, you'll have to do string matching and
  # hope they don't change anything.
  class CommandFailedError < Error; end
  
  # Represents an error outside the scope of normal API failures, including all IP-,
  # TCP-, and HTTP-level errors.
  class CommunicationError < Error; end
  
  # The API endpoint as a string
  URL = "https://admin.poslavu.com/cp/reqserv/"
  
  # Create a new Client with the specified credentials. These values can be
  # retrieved from this[http://admin.poslavu.com/cp/index.php?mode=api] page as
  # required.
  def initialize(dataname, token, key)
    @parameters = {
      'dataname' => dataname,
      'token' => token,
      'key' => key
    }
  end
  
  # Returns this Client's +dataname+.
  def dataname
    @parameters['dataname']
  end
  
  def inspect #:nodoc:
    "#<POSLavu::Client dataname=#{@parameters['dataname'].inspect}>"
  end
  
  # Returns an object that allows you to access the specified table.
  #
  #    # Find all orders for a given table
  #    client.table('orders').where('table_id' => 5).each { |row|
  #      # ...
  #    }
  #
  # See POSLavu::QueryScope for the query syntax.
  def table(table)
    POSLavu::QueryScope.new(self, table)
  end
  
  # Invokes a command, accepting a +parameters+ hash, and returning an array of
  # POSLavu::Row objects.
  #
  # The POSLavu API flattens all these parameters into a single POST request.
  # +command+ is broken out as a convenience because #table handles querying, and
  # specifying <tt>'cmd' => 'foo'</tt> repeatedly doesn't feel necessary.
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
        raise CommandFailedError, fragment.to_s
      end
    else
      # assume all the elements are <row>s, and let Row explode if we're wrong
      elements.map { |element|
        POSLavu::Row.from_nokogiri(element)
      }
    end
    
  rescue Faraday::Error::ClientError
    raise CommunicationError, $!.to_s
  end

  protected
  def connection #:nodoc:
    @connection ||= Faraday.new(:url => URL) { |faraday|
      faraday.request :url_encoded
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    }.tap { |connection|
      connection.headers[:user_agent] = "POSLavu Ruby #{POSLavu::VERSION}"
    }
  end
end
