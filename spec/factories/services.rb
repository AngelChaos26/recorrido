FactoryBot.define do
  factory :service do
    monitoring_shift { DateTime.current.beginning_of_week.to_i }
    association :company
    association :engineer

    trait :without_engineer do
      engineer { nil }
    end
  end
end
