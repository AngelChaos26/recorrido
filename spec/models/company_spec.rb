# spec/models/company_spec.rb
require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { build(:company) }
  
  describe 'associations' do
    it { is_expected.to have_many(:schedules).inverse_of(:company).dependent(:destroy) }
    it { is_expected.to have_many(:services).inverse_of(:company).dependent(:destroy) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(company).to be_valid
    end

    it "is not valid without a name" do
      company.name = nil
      expect(company).not_to be_valid
    end

    it "is not valid with a duplicate name" do
      create(:company, name: company.name)
      expect(company).not_to be_valid
    end
  end

  describe "#services_by_day" do
    it "groups services by date format" do
      date1 = DateTime.current.beginning_of_week
      date2 = DateTime.current.end_of_week
      
      service1 = create(:service, company: company, monitoring_shift: date1.to_i)
      service2 = create(:service, company: company, monitoring_shift: date1.to_i)
      service3 = create(:service, company: company, monitoring_shift: date2.to_i)

      expect(company.services_by_day).to eq({
        date1.strftime('%m-%d-%Y') => [service1, service2],
        date2.strftime('%m-%d-%Y') => [service3]
      })
    end
  end
end
