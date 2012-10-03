require 'multi_json'

# Represents a queryable dataset. Supports chaining.
class POSLavu::QueryScope
  include Enumerable
  
  attr_reader :table
  
  Operators = ['<=', '>=', '<', '>', '=', '<>', '!=', 'BETWEEN', 'LIKE', 'NOT LIKE']
  
  def filter(field, operator, value, value2=nil)
    operator = operator.to_s.upcase
    raise ArgumentError, "invalid operator" unless Operators.include?(operator)
    
    chain { |x|
      filter = { 'field' => field, 'operator' => operator, 'value1' => value.to_s }
      filter['value2'] = value2.to_s if operator == 'BETWEEN'
      x.filters << filter
    }
  end
  
  # returns records for a one-indexed page number
  def page(number, records_per_page=40)
    raise ArgumentError, "the first page number is 1 (got #{number})" if number < 1
    
    chain { |x|
      x.start_record = (number - 1) * records_per_page
      x.record_count = records_per_page
    }
  end
  
  # Finds records matching the provided hash
  def where(hash)
    scope = self
    hash.each { |key,value|
      scope = scope.filter(key, '=', value)
    }
    scope
  end
  
  def each(&block)
    if start_record
      # we represent a single page
      # do the fetching and iterate
      fetch_rows.each(&block)
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
        
        # bail out if we're done
        break if records.size < records_per_page
        
        page_number += 1
      }
      
    end
    
    self
  end
  
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
    @rows ||= @client.invoke('list', to_params)
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
