module BlueSkies
  module Workers
    autoload :CuratorFetch,   'workers/curator_fetch'
    autoload :Digest,         'workers/digest'
    autoload :LinkExtract,    'workers/link_extract'
    autoload :LinkShareCount, 'workers/link_share_count'
    autoload :NewRecipientNotify, 'workers/new_recipient_notify'
  end
end

# Scheduled workers need explicit laoding
require 'workers/curate'
require 'workers/links_extract'
require 'workers/links_share_count'
