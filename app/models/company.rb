class Company < ApplicationRecord
    has_many :schedules, class_name: "Company::Schedule", inverse_of: :company, foreign_key: :company_id
    has_many :services, class_name: "Service", inverse_of: :company, foreign_key: :company_id
    
    def schedules_by_week_number
        schedules.group_by { |schedule| schedule.week_number }
    end
    
    def services_by_day
        services.group_by { |service| service.date_format }
    end
end