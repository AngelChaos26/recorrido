class Service < ApplicationRecord
    has_many :service_engineers, class_name: "::Service::Engineer", inverse_of: :service, foreign_key: :service_id, dependent: :destroy
    has_many :engineers, through: :service_engineers
    
    belongs_to :company, class_name: "Company", inverse_of: :services, foreign_key: :company_id
    belongs_to :engineer, class_name: "::Engineer", inverse_of: :monitoring, foreign_key: :engineer_id, optional: true
    
    scope :by_range, -> (from, to) { where("datetime(services.monitoring_shift, 'unixepoch') BETWEEN ? AND ?", from, to) }
    
    def date_format
        Time.at(monitoring_shift).strftime("%m-%d-%Y")
    end
    
    def hour_format
        Time.at(monitoring_shift).strftime("%H:%M")
    end
end
