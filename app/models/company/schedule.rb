class Company::Schedule < ApplicationRecord
    belongs_to :company, class_name: "::Company", inverse_of: :schedules, foreign_key: :company_id
     
    validates :week_number, presence: true
    
    def end_time_format
        end_time.hour.zero? && end_time.min.zero? ? end_time + 1.day : end_time
    end
end
