# spec/models/service_spec.rb
require 'rails_helper'

RSpec.describe Service, type: :model do
  describe 'associations' do
    it { should have_many(:service_engineers).dependent(:destroy) }
    it { should have_many(:engineers).through(:service_engineers) }
    it { should belong_to(:company) }
    it { should belong_to(:engineer).optional }
  end

  describe 'scopes' do
    let!(:current_week) { Time.zone.now.beginning_of_week }
    let!(:service1) { create(:service, monitoring_shift: current_week + 1.day.to_i) }
    let!(:service2) { create(:service, monitoring_shift: current_week + 6.days.to_i) }
    let!(:service3) { create(:service, monitoring_shift: current_week + 1.day.ago.to_i) }
    let!(:service4) { create(:service, monitoring_shift: current_week + 5.days.ago.to_i) }

    it 'returns services within the specified range' do
      from = Time.zone.now.beginning_of_week.beginning_of_day
      to = Time.zone.now.end_of_week.end_of_day
      expect(Service.by_range(from, to)).to     include(service1, service2)
      expect(Service.by_range(from, to)).not_to include(service3, service4)
    end
  end

  describe 'instance methods' do
    let(:service) { create(:service, monitoring_shift: Time.zone.now.to_i) }

    it 'formats the date correctly' do
      expect(service.date_format).to eq(Time.zone.now.strftime('%m-%d-%Y'))
    end

    it 'formats the hour correctly' do
      expect(service.hour_format).to eq(Time.zone.now.strftime('%H:%M'))
    end
  end
end
