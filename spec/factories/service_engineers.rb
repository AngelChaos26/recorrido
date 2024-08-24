FactoryBot.define do
  factory :service_engineer, class: 'Service::Engineer' do
    association :service
    association :engineer
  end
end
