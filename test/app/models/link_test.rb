require 'test_helper'

describe 'Link' do
  let(:model) { BlueSkies::Models::Link }

  describe '.ranked_for_recipient' do
    let(:now) { Time.now }
    let(:skydiving) { BlueSkies::Models::Interest.create(name: 'skydiving')}
    let(:paragliding) { BlueSkies::Models::Interest.create(name: 'paragliding')}
    let(:recipient) { BlueSkies::Models::Recipient.create(email: 'tim@blueskies.io')}
    let(:curator_1) { BlueSkies::Models::Curator.create(facebook_identifier: 'foo')}
    let(:curator_2) { BlueSkies::Models::Curator.create(facebook_identifier: 'bar')}
    let(:link_1) { model.create(url: 'http://blueskies.io/1', last_curated_at: now, extracted_at: now, created_at: now - 1)}
    let(:link_2) { model.create(url: 'http://blueskies.io/2', last_curated_at: now, extracted_at: now, created_at: now)}

    describe 'included' do
      describe 'without common interest' do
        it 'is not included' do
          recipient.add_interest(skydiving)
          link_1.add_interest(paragliding)
          link_1.add_curator(curator_1)
          link_1.reload

          assert_empty model.ranked_for_recipient(recipient)
        end
      end

      describe 'not recently curated' do
        it 'is not included' do
          recipient.add_interest(skydiving)
          link_1.add_interest(skydiving)
          link_1.add_curator(curator_1)
          link_1.reload
          link_1.update(last_curated_at: now - 60 * 60 * 24 * 365)

          assert_empty model.ranked_for_recipient(recipient)
        end
      end

      describe 'not extracted' do
        it 'is not included' do
          recipient.add_interest(skydiving)
          link_1.add_interest(skydiving)
          link_1.add_curator(curator_1)
          link_1.reload
          link_1.update(extracted_at: nil)

          assert_empty model.ranked_for_recipient(recipient)
        end
      end

      describe 'already digests' do
        it 'is not included' do
          recipient.add_interest(skydiving)
          link_1.add_interest(skydiving)
          link_1.add_curator(curator_1)
          link_1.reload

          digest = BlueSkies::Models::Digest.create(recipient: recipient)
          digest.add_link(link_1)

          assert_empty model.ranked_for_recipient(recipient)
        end
      end
    end

    describe 'order' do
      it 'has most recent links first' do
        recipient.add_interest(skydiving)
        link_1.add_interest(skydiving)
        link_1.add_curator(curator_1)
        link_1.reload
        link_2.add_interest(skydiving)
        link_2.add_curator(curator_1)
        link_2.reload

        link_1.update(created_at: now - 60 * 60 * 24 * 10)
        link_2.update(created_at: now - 60 * 60 * 24 * 1)

        ranked = model.ranked_for_recipient(recipient).all

        assert_equal link_2.id, ranked[0].id
        assert_equal link_1.id, ranked[1].id
      end

      it 'has links with most interest in common first' do
        recipient.add_interest(skydiving)
        recipient.add_interest(paragliding)
        link_1.add_interest(skydiving)
        link_1.add_interest(paragliding)
        link_1.add_curator(curator_1)
        link_1.reload
        link_2.add_interest(skydiving)
        link_2.add_curator(curator_1)
        link_2.reload

        puts model.ranked_for_recipient(recipient).sql
        ranked = model.ranked_for_recipient(recipient).all

        assert_equal link_1.id, ranked[0].id
        assert_equal link_2.id, ranked[1].id
      end

      it 'has links with most curators first' do
        recipient.add_interest(skydiving)
        link_1.add_interest(skydiving)
        link_1.add_curator(curator_1)
        link_1.add_curator(curator_2)
        link_1.reload
        link_2.add_interest(skydiving)
        link_2.add_curator(curator_2)
        link_2.reload

        ranked = model.ranked_for_recipient(recipient).all

        assert_equal link_1.id, ranked[0].id
        assert_equal link_2.id, ranked[1].id
      end

      it 'has links with most shares first' do
        recipient.add_interest(skydiving)
        link_1.add_interest(skydiving)
        link_1.add_curator(curator_1)
        link_1.reload
        link_2.add_interest(skydiving)
        link_2.add_curator(curator_1)
        link_2.reload

        link_1.update(share_count: 100)
        link_2.update(share_count: 1000)

        ranked = model.ranked_for_recipient(recipient).all

        assert_equal link_2.id, ranked[0].id
        assert_equal link_1.id, ranked[1].id
      end
    end
  end

  describe '#last_curated_at' do
    it 'is updated when adding a curator' do
      record = model.create(url: 'http://blueskies.io')
      assert_equal nil, record.last_curated_at
      curator = BlueSkies::Models::Curator.create(facebook_identifier: 'foo')
      record.add_curator(curator)
      record.reload
      refute_equal nil, record.last_curated_at
    end
  end

  describe '#add_curator' do
    it 'does not add duplicate' do
      record = model.create(url: 'http://blueskies.io')
      curator = BlueSkies::Models::Curator.create(facebook_identifier: 'foo')

      record.add_curator(curator)
      assert_equal [curator], record.curators
      record.add_curator(curator)
      assert_equal [curator], record.curators
    end
  end

  describe '#add_interest' do
    it 'does not add duplicate' do
      record = model.create(url: 'http://blueskies.io')
      interest = BlueSkies::Models::Interest.create(name: 'foo')

      record.add_interest(interest)
      assert_equal [interest], record.interests
      record.add_interest(interest)
      assert_equal [interest], record.interests
    end
  end

  describe '#image=' do
    it 'saves image data' do
      record = model.create(url: 'http://blueskies.io')
      record.update_all(image: {url: 'http://blueskies.io/foo.jpg'})

      assert_equal 'http://blueskies.io/foo.jpg', record.reload.image.url
    end
  end
end
