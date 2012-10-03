require 'spec_helper'

describe "Global aliases" do
  describe Poslavu do
    it { should eql(POSlavu) }
  end

  describe POSlavu do
    it { should eql(POSLavu) }
  end
end

