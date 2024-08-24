# spec/models/engineer_spec.rb
require 'rails_helper'

RSpec.describe Engineer, type: :model do
  describe 'associations' do
    it { should have_many(:service_engineers).dependent(:destroy) }
    it { should have_many(:services).through(:service_engineers) }
  end

  describe 'instance methods' do
    let(:engineer) { create(:engineer, first_name: 'John', last_name: 'Doe') }

    it 'returns the full name' do
      expect(engineer.full_name).to eq('John Doe')
    end
  end
end
