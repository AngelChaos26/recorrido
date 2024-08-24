require 'rails_helper'

RSpec.describe Company::Schedule, type: :model do
  describe 'associations' do
    it { should belong_to(:company) }
  end

  describe 'validations' do
    it { should validate_presence_of(:week_number) }
    it { should validate_numericality_of(:week_number) }
  end

  describe 'instance methods' do
    let(:company) { create(:company) }
    let(:schedule) do
      create(:company_schedule,
             company: company)
    end

    describe '#end_time_format' do
      it 'returns end_time + 1 day if end_time hour and min are zero' do
        schedule.update(end_time: Time.zone.now.beginning_of_day)
        expect(schedule.end_time_format).to eq(schedule.end_time + 1.day)
      end

      it 'returns end_time as is if end_time hour and min are not zero' do
        expect(schedule.end_time_format).to eq(schedule.end_time)
      end
    end

    describe '#hours_range' do
      it 'returns the correct range of hours' do
        expected_hours = [
          (schedule.start_time + 0 * 60).strftime('%H:%M'),
          (schedule.start_time + 60 * 60).strftime('%H:%M'),
          (schedule.start_time + 120 * 60).strftime('%H:%M'),
          (schedule.start_time + 180 * 60).strftime('%H:%M')
        ]
        expect(schedule.hours_range).to eq(expected_hours)
      end
    end
  end
end
