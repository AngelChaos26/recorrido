class Company < ApplicationRecord
    has_many :schedules, class_name: "Company::Schedule", inverse_of: :company, foreign_key: :company_id
    has_many :services, class_name: "Service", inverse_of: :company, foreign_key: :company_id
end