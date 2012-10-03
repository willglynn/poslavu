describe POSLavu::QueryScope do
  let(:dataname) { 'dataname' }
  let(:token) { 'token' }
  let(:key) { 'key' }
  let(:table_name) { 'table' }
  let(:client) { POSLavu::Client.new(dataname, token, key) }
  let(:table) { client.table(table_name) }
  
  it "should be returned by POSLavu::Client#table" do
    table.should be_kind_of POSLavu::QueryScope
  end
  
  describe "#filter" do
    before { poslavu_api_stub { POSLavu::Row.new } }
    ['<=', '>=', '<', '>', '=', '<>', '!=', 'LIKE', 'NOT LIKE'].each { |operator|
      specify "filters using #{operator}" do
        table.filter('a', operator, 'b').page(1, 1).each {}
        WebMock.should have_requested_poslavu_api('filters' => '[{"field":"a","operator":"' + operator + '","value1":"b"}]')
      end
    }
    
    specify "filters using BETWEEN" do
      table.filter('a', 'BETWEEN', 'b', 'c').page(1, 1).each {}
      WebMock.should have_requested_poslavu_api('filters' => '[{"field":"a","operator":"BETWEEN","value1":"b","value2":"c"}]')
    end
    
    
    it "chains multiple filters" do
      table.filter('a', '=', 'b').filter('c', '=', 'd').page(1, 1).each {}
      WebMock.should have_requested_poslavu_api('filters' => '[{"field":"a","operator":"=","value1":"b"},{"field":"c","operator":"=","value1":"d"}]')
    end
    
    it "preserves pagination when filtering" do
      base = table.page(2, 47)
      filtered = base.filter('field', '=', 'value')
      filtered.instance_variable_get(:@start_record).should eq 47
      filtered.instance_variable_get(:@record_count).should eq 47
    end
  end
  
  describe "#where" do
    before { poslavu_api_stub { POSLavu::Row.new } }
    
    it "creates proper JSON filter" do
      table.where('a' => 'b', 'c' => 'd').page(1, 1).each {}
      WebMock.should have_requested_poslavu_api('filters' => '[{"field":"a","operator":"=","value1":"b"},{"field":"c","operator":"=","value1":"d"}]')
    end
  end
  
  describe "#each" do
    describe "for a single page" do
      let(:page_size) { 40 }
      before { poslavu_api_stub { (1..page_size).map { |n| POSLavu::Row.new('counter' => n) } } }
      subject { table.page(1, page_size) }
    
      it "returns rows" do
        collected = []
        subject.each { |value| collected << value }
        collected.size.should eq 40
      end
      
      it "memoizes results" do
        subject.each { }
        subject.each { }
        WebMock.should have_requested_poslavu_api.once
      end
      
      it "re-requests when chained" do
        subject.each { }
        child = subject.filter('foo', '=', 'bar')
        child.each { }
        WebMock.should have_requested_poslavu_api.twice
      end
      
      it "passes filter as JSON" do
        subject.filter('a', '=', 'b').each {}
        WebMock.should have_requested_poslavu_api('filters' => '[{"field":"a","operator":"=","value1":"b"}]')
      end
    end
    
    describe "for all pages when there is only one page" do
      before {
        poslavu_api_stub('limit' => '0,100') { (1..50).map { |n| POSLavu::Row.new('counter' => n) } }
      }
      
      subject { table }
      
      it "returns all results" do
        rows = 0
        subject.each { rows += 1 }
        rows.should eq 50
      end
      
      it "requests all pages" do
        subject.each {}
        WebMock.should have_requested_poslavu_api.once
      end
      
      it "memoizes results" do
        subject.each {}
        subject.each {}
        WebMock.should have_requested_poslavu_api.once
      end
    end
    
    describe "for all pages when there is more than one" do
      let(:full_page) { (1..100).map { |n| POSLavu::Row.new('counter' => n) } }
      let(:half_page) { full_page[0,50] }
      
      before {
        poslavu_api_stub('limit' => '0,100') { full_page }
        poslavu_api_stub('limit' => '100,100') { full_page }
        poslavu_api_stub('limit' => '200,100') { half_page }
      }

      subject { table }
      
      it "returns all results" do
        rows = 0
        subject.each { rows += 1 }
        rows.should eq 250
      end
      
      it "requests all pages" do
        subject.each {}
        WebMock.should have_requested_poslavu_api.times(3)
      end
      
      it "does not memoize results" do
        subject.each {}
        subject.each {}
        WebMock.should have_requested_poslavu_api.times(6)
      end
    end
    
  end
  
end