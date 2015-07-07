require 'test_helper'

describe 'FacebookFetcher' do
  describe '.response' do
    it 'calls API' do
      response = {'foo' => 'bar'}
      stub_request(
        :get,
        %r{graph\.facebook\.com/v2.3/WorldWingsuitLeague/links}
      ).to_return(
        headers: {
          'Content-Type' => 'application/json; charset=UTF-8'
        },
        status: 200,
        body: response.to_json
      )
      assert_equal response , BlueSkies::FacebookFetcher.response('WorldWingsuitLeague')
    end
  end

  describe '.fetch' do
    def fetch_from(response, &block)
      page = 'WorldWingsuitLeague'

      response['data'].each do |raw|
        link = raw['link']
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
      end

      BlueSkies::FacebookFetcher.stub(:response, response) do
        yield(BlueSkies::FacebookFetcher.fetch(page))
      end
    end

    it 'returns links' do
      links = [
        'https://www.change.org/p/u-s-national-park-service-remove-base-jumping-from-u-s-national-park-aerial-delivery-law?recruiter=302699141&utm_source=share_petition&utm_medium=facebook&utm_campaign=share_facebook_responsive&utm_term=des-md-no_src-no_msg',
        'http://www.youtube.com/watch?v=Czy0pXRRZcs'
      ]

      fetch_from({
        'data' => [
          {
            'link' => links[0],
            'id' => '828630550550640',
            'created_time' => '2015-05-27T01:36:01+0000'
          },
          {
            'link' => links[1],
            'id' => '821939901219705',
            'created_time' => '2015-05-11T21:55:04+0000'
          },
        ]
      }) do |results|
        assert_equal links, results
      end
    end

    it 'ignores relative urls' do
      fetch_from({
        'data' => [
          {
            'link' => '/JokkeSommerOfficial/videos/1077342972293068/',
            'id' => '825542734192755',
            'created_time' => '2015-05-19T20:42:59+0000'
          }
        ]
      }) do |results|
        assert_equal 0, results.size
      end
    end

    it 'ignores facebook urls' do
      fetch_from({
        'data' => [
          {
            'link' => 'https://www.facebook.com/Seb.Alvarez01/photos/a.544648558965611.1073741828.533147086782425/819552994808498/?type=1',
            'id' => '828525610561134',
            'created_time' => '2015-05-26T19:12:12+0000'
          }
        ]
      }) do |results|
        assert_equal 0, results.size
      end
    end
  end
end
