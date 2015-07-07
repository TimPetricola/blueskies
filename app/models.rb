Sequel.default_timezone = :utc

Sequel.extension :core_extensions
Sequel.extension :pg_array
Sequel.extension :pg_array_ops
Sequel.extension :pg_hstore

Sequel::Model.plugin :timestamps
Sequel::Model.plugin :serialization

Sequel::Plugins::Serialization.register_format(:schedule_yaml,
  lambda { |v| v.to_yaml },
  lambda { |v| IceCube::Schedule.from_yaml(v) }
)

module BlueSkies
  module Models
    autoload :Curator,   'models/curator'
    autoload :Digest,    'models/digest'
    autoload :Image,     'models/image'
    autoload :Interest,  'models/interest'
    autoload :Link,      'models/link'
    autoload :Recipient, 'models/recipient'
  end
end
