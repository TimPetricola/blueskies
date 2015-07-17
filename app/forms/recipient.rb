module BlueSkies
  module Forms
    class Recipient
      attr_reader :errors

      def initialize(params = {})
        @params = params
        @errors = {}
      end

      def interest_checked?(interest)
        interests_ids.include?(interest.id)
      end

      def interests_ids
        params[:interests] || []
      end

      def timezone
        params[:timezone].to_f
      end

      def email
        params[:email]
      end

      def biweekly?
        !params[:biweekly].nil?
      end

      def valid?
        errors[:interests] = :blank if interests_ids.empty?
        errors[:email] = :blank if email.nil? || email.empty?

        errors.empty?
      end

      private

      attr_reader :params
    end
  end
end
