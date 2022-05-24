require 'spec_helper'
require 'alaveteli_features/feature'
require_relative 'mocks/user'

RSpec.describe AlaveteliFeatures::Feature::CollectionMethods do
  let(:base_collection) do
    AlaveteliFeatures::Collection.new(AlaveteliFeatures::Feature)
  end

  let(:actor) { MockUser.new(1) }
  let!(:feature_1) { base_collection.add(:feature_1) }
  let!(:feature_2) { base_collection.add(:feature_2) }

  before do
    AlaveteliFeatures.backend.enable_actor(:feature_1, actor)
  end

  describe '#with_actor' do
    it 'sets actor on collection' do
      expect { base_collection.with_actor(actor) }.to \
        change(base_collection, :actor).from(nil).to(actor)
    end

    it 'sets actor on instances' do
      expect { base_collection.with_actor(actor) }.to \
        change(feature_1, :actor).from(nil).to(actor)
    end

    it 'returns collection' do
      expect(base_collection.with_actor(actor)).to eq(base_collection)
    end
  end

  describe '#enabled?' do
    context 'without actor' do
      it 'raises ActorNotDefinedError' do
        expect { base_collection.enabled?(:feature_1) }.to raise_error(
          AlaveteliFeatures::Feature::ActorNotDefinedError
        )
      end
    end

    context 'with actor' do
      let(:collection) { base_collection.with_actor(actor) }

      it 'returns true is feature is enabled' do
        expect(collection.enabled?(:feature_1)).to eq(true)
      end

      it 'returns false is feature is disabled' do
        expect(collection.enabled?(:feature_2)).to eq(false)
      end
    end
  end

  describe '#assign_features' do
    context 'without actor' do
      it 'raises ActorNotDefinedError' do
        expect { base_collection.assign_features([:feature_2]) }.to raise_error(
          AlaveteliFeatures::Feature::ActorNotDefinedError
        )
      end
    end

    context 'with actor' do
      let(:collection) { base_collection.with_actor(actor) }

      it 'enabled features' do
        expect { collection.enable_features([:feature_2]) }.to \
          change { collection.enabled?(:feature_2) }.from(false).to(true)
      end

      it 'disable other features' do
        AlaveteliFeatures.backend.enable_actor(:feature_1, actor)
        expect { collection.enable_features([:feature_2]) }.to \
          change { collection.enabled?(:feature_1) }.from(true).to(false)
      end
    end
  end
end
