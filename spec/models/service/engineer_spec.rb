# spec/models/service/engineer_spec.rb
require 'rails_helper'

RSpec.describe Service::Engineer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:service) }
    it { is_expected.to belong_to(:engineer) }
  end

  describe 'callbacks' do
    let(:service_engineer) { build(:service_engineer) }

    it 'calls the MonitoringEngineersJob after destroy' do
      service_engineer.save!
      expect(MonitoringEngineersJob).to receive(:perform_later).with(service_engineer.service_id)
      service_engineer.destroy!
    end
  end
end
