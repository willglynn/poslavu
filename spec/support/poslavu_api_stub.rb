module POSLavu::APIStub
  def poslavu_api_stub(params = {}, &block)
    stub = stub_http_request(:post, POSLavu::Client::URL).with(:body => hash_including(params))
    
    if block
      stub.to_return { |request|
        response = block.call(request)
      
        if response.instance_of?(Hash)
          response
        else
          body = case response
          when Array then response.map(&:to_xml).join    # assume array of rows
          when POSLavu::Row then response.to_xml
          else response.to_s
          end

          { :body => body, :status => 200 }
        end
      }
    end
    
    stub
  end
  
  def have_requested_poslavu_api(params = {})
    expected_filters = params.delete('filters')
    
    have_requested(:post, POSLavu::Client::URL).with(:body => hash_including(params)) { |req|
      if expected_filters
        # filters is JSON, which needs to be an equivalent data structure
        params = WebMock::Util::QueryMapper.query_to_values(req.body)
        
        if actual_filters = params['filters']
          # request has parameter
          # parse both
          expected = MultiJson.load(expected_filters)
          actual = MultiJson.load(actual_filters)
          
          # compare
          expected == actual
        else
          # request missing parameter; fail
          false
        end
        
      else
        # no filters parameter; match
        true
      end
    }
  end
end
