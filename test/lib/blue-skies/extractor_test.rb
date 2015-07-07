require 'test_helper'
require 'ostruct'

describe BlueSkies::Extractor do
  it 'calls Embedly extractor' do
    url = 'http://blueskies.io'

    BlueSkies::Extractors::Embedly.stub(:extract, {foo: 'bar'}) do
      assert_equal({foo: 'bar'}, BlueSkies::Extractor.extract(url))
    end
  end
end
