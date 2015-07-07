module BlueSkies
  module Workers
    autoload :CuratorFetch,   'workers/curator_fetch'
    autoload :Digest,         'workers/digest'
    autoload :LinkExtract,    'workers/link_extract'
    autoload :LinkShareCount, 'workers/link_share_count'
  end
end

# Scheduled workers need explicit laoding
require 'workers/curate'
require 'workers/links_extract'
require 'workers/links_share_count'
