require 'spec_helper'

describe POSLavu::Client do
  let(:dataname) { 'dataname' }
  let(:token) { 'token' }
  let(:key) { 'key' }
  let(:client) { POSLavu::Client.new(dataname, token, key) }
  subject { client }
  
  describe "invoke" do
    describe "HTTP requests" do
      before {
        poslavu_api_stub
        client.invoke('command', 'abc' => 'def') rescue nil
      }

      specify("should request with 'dataname' parameter") { WebMock.should have_requested_poslavu_api('dataname' => dataname) }
      specify("should request with 'token' parameter") { WebMock.should have_requested_poslavu_api('token' => token) }
      specify("should request with 'key' parameter") { WebMock.should have_requested_poslavu_api('key' => key) }
      specify("should request with 'cmd' parameter") { WebMock.should have_requested_poslavu_api('cmd' => 'command') }
      specify("should request with hash parameter") { WebMock.should have_requested_poslavu_api('abc' => 'def') }
      specify("should request with User-Agent header") { WebMock.should have_requested_poslavu_api.with(:headers => { 'User-Agent' => "POSLavu Ruby #{POSLavu::VERSION}"}) }
    end
    
    describe "error handling" do
      it "raises errors returned as body text" do
        poslavu_api_stub { 'this is an error' }
        lambda { client.invoke('command') }.should raise_exception POSLavu::Client::Error, "this is an error"
      end

      # not yet observed in the wild
      it "raises errors for 500 responses" do
        poslavu_api_stub.to_return(:status => 500)
        lambda { client.invoke('command') }.should raise_exception POSLavu::Client::Error
      end

      it "raises errors for timeouts" do
        poslavu_api_stub.to_timeout
        lambda { client.invoke('command') }.should raise_exception POSLavu::Client::Error
      end
    end

    describe "response parsing" do
      before { poslavu_api_stub { response } }
      subject { client.invoke('command') }
      
      describe "empty string" do
        let(:response) { "" }
        it { should be_kind_of Array }
        it { should be_empty }
      end
      
      describe "single row" do
        let(:response) { [POSLavu::Row.new(:foo => 'bar', :baz => 'quxx')] }
        it { should be_kind_of Array }
        it("should match the expected value") { subject.should eql response }
      end
      
      describe "multiple rows" do
        let(:response) { (1..10).map { |n| POSLavu::Row.new(:counter => n) } }
        it("should match the expected value") { subject.should eql response }
      end
    end
  end
end
