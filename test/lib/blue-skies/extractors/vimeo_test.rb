require 'test_helper'
require 'ostruct'

describe BlueSkies::Extractors::Vimeo do
  describe '.video_id' do
    it 'is extracted from Vimeo url' do
      [
        'http://vimeo.com/111824606',
        'http://player.vimeo.com/video/111824606',
        'http://player.vimeo.com/video/111824606?title=0&amp;byline=0&amp;portrait=0',
        'http://vimeo.com/channels/blueskies/111824606',
        'http://vimeo.com/channels/staffpicks/111824606',
        'http://vimeo.com/channels/blueskies/111824606'
      ].each do |url|
        assert_equal 111824606, BlueSkies::Extractors::Vimeo.send(:video_id, url)
      end
    end

    it 'is nil for non-Vimeo url' do
      [
        'http://youtube.com/11586361',
        'http://vimeo.com/videoschool',
        'http://vimeo.com/videoschool/archive/behind_the_scenes',
        'http://vimeo.com/forums/screening_room',
        'http://vimeo.com/forums/screening_room/topic:42708'
      ].each do |url|
        assert_equal nil, BlueSkies::Extractors::Vimeo.send(:video_id, url)
      end
    end
  end

  describe '.response' do
    it 'calls API' do
      url = 'http://vimeo.com/111824606'

      stub_request(:get, 'https://vimeo.com/api/v2/video/111824606.json')
        .to_return(
          headers: {
            'Content-Type' => 'application/json'
          },
          body: [
            {
              'id' => 111824606,
              'tags' => 'xalps, paragliding'
            }
          ].to_json
        )

      response = BlueSkies::Extractors::Vimeo.send(:response, url)
      assert_equal({'id' => 111824606, 'tags' => 'xalps, paragliding'}, response)
    end

    it 'is nil for unexisting video' do
      url = 'http://vimeo.com/10000000000'

      stub_request(:get, 'https://vimeo.com/api/v2/video/10000000000.json')
        .to_return(
          status: 404,
          headers: {
            'Content-Type' => 'text/html; charset=UTF-8'
          },
          body: '10000000000 not found.'
        )

      response = BlueSkies::Extractors::Vimeo.send(:response, url)
      assert_equal(nil, response)
    end
  end

  describe '.extract' do
    def extract_from(response, &block)
      url = 'http://vimeo.com/111824606'
      source = Minitest::Mock.new
      source.expect(:url, url)

      BlueSkies::Extractors::Vimeo.stub(:response, response) do
        data = BlueSkies::Extractors::Vimeo.extract(source, OpenStruct.new)
        yield(data)
      end

      source.verify
    end

    it 'returns keywords' do
      response = {
        'tags' => 'xalps, x-alps, paragliding, into the sky'
      }
      expected = Set.new(['xalps', 'x-alps', 'paragliding', 'into the sky'])

      extract_from(response) do |data|
        assert_equal expected, data.keywords
      end
    end
  end
end
