require 'test_helper'
require 'ostruct'

describe BlueSkies::Extractors::Embedly do
  describe '.response' do
    it 'calls API' do
      url = 'http://blueskies.io'

      stub_request(:get, 'https://api.embed.ly/1/extract')
        .with(query: hash_including(url: url))
        .to_return(
          headers: {
            'Content-Type' => 'application/json'
          },
          body: {
            foo: 'bar'
          }.to_json
        )

      response = BlueSkies::Extractors::Embedly.send(:response, url)
      assert_equal({'foo' => 'bar'}, response)
    end
  end

  describe '.extract' do
    def extract_from(response, &block)
      url = 'http://blueskies.io'
      source = Minitest::Mock.new
      source.expect(:url, url)

      BlueSkies::Extractors::Embedly.stub(:response, response) do
        data = BlueSkies::Extractors::Embedly.extract(source, OpenStruct.new)
        yield(data)
      end

      source.verify
    end

    it 'returns title' do
      title = "BASE jumping from the world's highest zipline"
      response = {'title' => title}

      extract_from(response) do |data|
        assert_equal title, data.title
      end
    end

    it 'returns description' do
      description = 'Earlier this year, Skydive Dubai hooked up with...'
      response = {'description' => description}

      extract_from(response) do |data|
        assert_equal description, data.description
      end
    end

    it 'returns keywords' do
      response = {
        'keywords' => [
          {
            'score' => 46,
            'name' => 'exit'
          },
          {
            'score' => 40,
            'name' => 'dreamjump'
          },
          {
            'score' => 28,
            'name' => 'skydive'
          },
        ]
      }
      expected = Set.new(%w(exit dreamjump skydive))

      extract_from(response) do |data|
        assert_equal expected, data.keywords
      end
    end

    describe 'images' do
      def extract_images(&block)
        response = {
          'images' => [
            {
              'caption' => nil,
              'url' => 'http://blueskies.io/foo.jpg',
              'height' => 999,
              'width' => 1500,
              'colors' => [
                {
                  'color' => [177, 181, 182],
                  'weight' => 0.634521484375
                },
                {
                  'color' => [106, 120, 108],
                  'weight' => 0.302978515625
                }
              ],
              'entropy' => 5.77993911192,
              'size' => 1723611
            },
            {
              'caption' => nil,
              'url' => 'http://blueskies.io/bar.jpg',
              'height' => 213,
              'width' => 320,
              'colors' => [
                {
                  'color' => [106, 120, 108],
                  'weight' => 0.264892578125
                },
                {
                  'color' => [199, 203, 198],
                  'weight' => 0.376953125
                }
              ],
              entropy: 6.479291027464924,
              size: 31143
            }
          ]
        }

        extract_from(response, &block)
      end

      it 'returns images' do
        extract_images do |data|
          assert_equal 2, data.images.size
        end
      end

      it 'has url, height and width' do
        extract_images do |data|
          assert_equal 'http://blueskies.io/foo.jpg', data.images.first.url
          assert_equal 999, data.images.first.height
          assert_equal 1500, data.images.first.width
        end
      end

      it 'has hexadecimal color' do
        extract_images do |data|
          assert_equal '#b1b5b6', data.images.first.color
        end
      end

      it 'has color with most weight' do
        extract_images do |data|
          assert_equal '#c7cbc6', data.images.last.color
        end
      end
    end
  end
end
