module BlueSkies
  module Routes
    class Base < Sinatra::Base
      configure do
        set :views, 'app/views'
      end

      helpers do
        def asset_path(asset)
          '/assets/' + JSON.parse(File.read('assets-manifest.json')).fetch(asset)
        end

        def ordinal(number)
          abs_number = number.to_i.abs

          if (11..13).include?(abs_number % 100)
            "th"
          else
            case abs_number % 10
              when 1; "st"
              when 2; "nd"
              when 3; "rd"
              else    "th"
            end
          end
        end
      end

      not_found do
        erb :'404'
      end
    end
  end
end
