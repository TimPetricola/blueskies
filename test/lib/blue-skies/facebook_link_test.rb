require 'test_helper'

describe 'FacebookLink' do
  describe '.response' do
    it 'calls API' do
      url = 'http://vimeo.com/111824606'

      response = {
        'og_object' => {
          'url' => url
        },
        'share' => {
          'share_count' => 421
        }
      }
      stub_request(
        :get,
        "https://graph.facebook.com/v2.3/#{CGI.escape(url)}?access_token=#{ENV['FACEBOOK_ACCESS_TOKEN']}"
      ).to_return(
        headers: {
          'Content-Type' => 'application/json; charset=UTF-8'
        },
        status: 200,
        body: response.to_json
      )
      assert_equal response, BlueSkies::FacebookLink.send(:response, url)
    end
  end

  describe 'info' do
    def fetch_from(response, &block)
      link = 'http://vimeo.com/111824606'

      stub_request(:get, "https://graph.facebook.com/v2.3/#{CGI.escape(link)}?access_token=#{ENV['FACEBOOK_ACCESS_TOKEN']}")
        .to_return(
          headers: {
            'Content-Type' => 'application/json; charset=UTF-8'
          },
          status: 200,
          body: {
            'og_object' => {
              'url' => link
            }
          }.to_json
        )

      BlueSkies::FacebookLink.stub(:response, response) do
        yield(BlueSkies::FacebookLink.info(link))
      end
    end

    it 'returns url' do
      url = 'http://vimeo.com/111824606'
      fetch_from({
        'og_object' => {
          'url' => url
        }
      }) do |data|
        assert_equal url, data.url
      end
    end

    it 'returns shares count' do
      share_count = 12000
      fetch_from({
        'share' => {
          'share_count' => share_count
        }
      }) do |data|
        assert_equal share_count, data.share_count
      end
    end
  end
end
