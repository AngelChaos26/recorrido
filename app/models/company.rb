class Company < ApplicationRecord
    has_many :schedules, class_name: "Company::Schedule", inverse_of: :company, foreign_key: :company_id
    has_many :services, class_name: "Service", inverse_of: :company, foreign_key: :company_id
    
    after_create :call_company_schedule_service
    
    validates :name, uniqueness: true
    
    def schedules_by_week_number
        schedules.group_by { |schedule| schedule.week_number }
    end
    
    def services_by_day
        services.group_by { |service| service.date_format }
    end
    
    private
    
    def call_company_schedule_service
        CompanySchedulesJob.perform_now(self.reload.id)
    end
end