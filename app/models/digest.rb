module BlueSkies
  module Models
    class Digest < Sequel::Model
      many_to_one :recipient
      many_to_many :links

      def deliver!(delivery_time: nil)
        Delivery.new(self).deliver(at: delivery_time)
      end
    end
  end
end
