require 'spec_helper'

describe POSLavu::Row do
  subject { POSLavu::Row.new }
  
  it { should be_kind_of Hash }
  
  describe "new" do
    subject { POSLavu::Row.new(hash) }

    describe "hash with symbol key and string value" do
      let(:hash) do { :a => 'b' } end
      its(:keys) { should eql [:a] }
      its(:values) { should eql ['b'] }
    end

    describe "hash with string key and integer value" do
      let(:hash) do { 'a' => 0 } end
      its(:keys) { should eql [:a] }
      its(:values) { should eql ['0'] }
    end
  end
  
  describe "#from_xml" do
    subject { POSLavu::Row.from_xml(string) }
    
    describe "<row/>" do
      let(:string) { "<row/>" }
      it { should be_empty }
    end
    
    describe "<row><foo>bar</foo></row>" do
      let(:string) { "<row><foo>bar</foo></row>" }
      its(:keys) { should eq [:foo] }
      its(:values) { should eq ['bar'] }
      
      it("to_xml should match") {
        subject.to_xml.gsub(/\s/, '').should eq(string.gsub(/\s/, ''))
      }
    end
    
    describe "failure cases" do
      def self.should_fail(string)
        subject { lambda { POSLavu::Row.from_xml(string) } }
        it("#{string.inspect} should raise ArgumentError") { should raise_exception ArgumentError }
      end
      
      should_fail nil
      should_fail ""
      should_fail "<not_a_row_element/>"
      should_fail "<row/><row/>"
      should_fail "<result><row/></result>"
    end

  end
end
