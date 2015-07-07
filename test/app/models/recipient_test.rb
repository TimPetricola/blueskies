require 'test_helper'

describe 'Recipient' do
  let(:model) { BlueSkies::Models::Recipient }

  describe '#create_and_send_digest' do
    it { skip 'needs testing' }
  end

  describe '#update_schedule' do
    it { skip 'needs testing' }
  end

  describe '#enqueue_next_digest' do
    it { skip 'needs testing' }
  end

  describe 'token' do
    it 'is generated on create' do
      recipient = model.create(email: 'tim@blueskies.io')
      refute_nil recipient.token
    end
  end

  describe '#interests_ids_dataset' do
    it 'returns a dataset with ids' do
      recipient = model.create(email: 'tim@blueskies.io')
      paragliding = BlueSkies::Models::Interest.create(name: 'Paragliding')
      skydiving = BlueSkies::Models::Interest.create(name: 'Skydiving')
      recipient.add_interest(paragliding)
      recipient.add_interest(skydiving)

      interests_ids = recipient.interests_ids_dataset

      assert_instance_of Sequel::Postgres::Dataset, interests_ids
      assert_equal(
        [paragliding.id, skydiving.id].to_set,
        interests_ids.map {|i| i[:id] }.to_set
      )
    end
  end

  describe '#digested_links_ids_dataset' do
    it 'returns a dataset with ids' do
      recipient = model.create(email: 'tim@blueskies.io')
      link = BlueSkies::Models::Link.create(url: 'http://blueskies.io/1')
      digest = BlueSkies::Models::Digest.create(recipient: recipient)
      digest.add_link(link)

      links_ids = recipient.digested_links_ids_dataset

      assert_instance_of Sequel::Postgres::Dataset, links_ids
      assert_equal(
        [link.id].to_set,
        links_ids.map {|i| i[:id] }.to_set
      )
    end
  end

  describe '#add_interest' do
    it 'does not add duplicate' do
      record = model.create(email: 'tim@blueskies.io')
      interest = BlueSkies::Models::Interest.create(name: 'foo')

      record.add_interest(interest)
      assert_equal [interest], record.interests
      record.add_interest(interest)
      assert_equal [interest], record.interests
    end
  end
end
