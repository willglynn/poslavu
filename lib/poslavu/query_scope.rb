require 'multi_json'

# QueryScope represents a retrievable set of records. You can obtain one by
# calling POSLavu::Client#table() for the table in question.
#
# Query scopes are chainable. Given an initial scope representing all records
# in a table, you may further restrict the records of interest by with #filter,
# #page, and #where.
#
# Query scopes are Enumerable. #each is the obvious access method, but #to_a,
# #map, #inject, and all your friends are also available.
#
# Query scopes are lazy loading. You can manipulate them as much as you want
# without performing any API calls. The request is actually performed once you
# call #each or any other Enumerable method. If you've called #page, the results
# are held in memory. If not, #each issues multiple requests (internally
# paginating) and does not hold the result in memory.
class POSLavu::QueryScope
  include Enumerable
  
  # The name of the table, as passed to POSLavu::Client#table
  attr_reader :table
  
  # The list of operators supported by the POSLavu API (and thus supported by #filter).
  Operators = ['<=', '>=', '<', '>', '=', '<>', '!=', 'BETWEEN', 'LIKE', 'NOT LIKE']
  
  # Returns a new QueryScope with the specified filter applied.
  #
  # The POSLavu API has a basic query language modeled after SQL, probably because
  # they're shoveling the filter straight into SQL. It supports restricting +field+s
  # using a set of Operators. All of them require a value for comparison, except
  # +BETWEEN+, which requires two values.
  #
  # +LIKE+ and +NOT LIKE+ accept +'%'+ as a wildcard. There is no mechanism for
  # pattern-matching strings containing a percent sign.
  def filter(field, operator, value, value2=nil)
    operator = operator.to_s.upcase
    raise ArgumentError, "invalid operator" unless Operators.include?(operator)
    
    chain { |x|
      filter = { 'field' => field, 'operator' => operator, 'value1' => value.to_s }
      filter['value2'] = value2.to_s if operator == 'BETWEEN'
      x.filters << filter
    }
  end
  
  # Returns a new QueryScope, restricting results to the specified page number.
  #
  # Pages are 1-indexed: the first page is page 1, not page 0.
  def page(number, records_per_page=40)
    raise ArgumentError, "the first page number is 1 (got #{number})" if number < 1
    
    chain { |x|
      x.start_record = (number - 1) * records_per_page
      x.record_count = records_per_page
    }
  end
  
  # Returns a new QueryScope, restricting results to rows matching the specified
  # hash. It is a convenience method around #filter. The following two statements
  # are exactly equivalent:
  #
  #     client.table('orders').where('table_id' => 4, 'no_of_checks' => 2)
  #     client.table('orders').filter('table_id', '=', 4).filter('no_of_checks', '=', 2)
  def where(hash)
    scope = self
    hash.each { |key,value|
      scope = scope.filter(key, '=', value)
    }
    scope
  end
  
  # Iterate over the records represented by this query scope.
  #
  # If this scope has an explicit #page set, the results will be retrieved and
  # memoized. Otherwise, this scope will internally paginate and make successive
  # requests, yielding each row in turn, and the results will not be memoized.
  def each(&block)
    if @rows
      # we've been memoized
      @rows.each(&block)
      
    elsif start_record
      # we represent a single page
      # do the fetching and iterate
      @rows = fetch_rows

      @rows.each(&block)
    else
      # we represent the whole set of possible records
      # fetch repeatedly, in pages
      page_number = 1
      records_per_page = 100
      
      loop {
        # create a scope for this page
        inner_scope = page(page_number, records_per_page)
        
        # fetch the records as an array
        records = inner_scope.to_a
        
        # pass them to the caller
        records.each(&block)
        
        # is this the last page?
        if records.size < records_per_page
          # was this the first page?
          if page_number == 1
            # this is the only page
            # memoize
            @rows = records
          end
          
          # regardless, we're done
          break
        end
        
        page_number += 1
      }
      
    end
    
    self
  end
  
  #:nodoc:
  protected
  attr_accessor :filters, :start_record, :record_count
  attr_accessor :rows
  
  def initialize(client, table)
    @client = client
    @table = table
    
    @filters = []
    @start_record = nil
    @record_count = nil
    @rows = nil
  end
  
  def chain(&block)
    dup.tap { |copy|
      copy.rows = nil
      yield(copy)
    }
  end
  
  def fetch_rows
    @client.invoke('list', to_params)
  end
  
  def to_params
    {
      'table' => @table,
      'limit' => "#{start_record},#{record_count}"
    }.tap do |params|
      params['filters'] = MultiJson.dump(filters) unless filters.empty?
    end
  end
end
