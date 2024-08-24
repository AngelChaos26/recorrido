FactoryBot.define do
  factory :company_schedule, class: 'Company::Schedule' do
    association :company
    week_number { 1 }
    start_time { Time.current.beginning_of_day }
    end_time { Time.current.beginning_of_day + 4.hours }
  end
end
