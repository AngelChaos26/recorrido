class Engineer < ApplicationRecord
    has_many :service_engineers, class_name: "Service::Engineer", inverse_of: :engineer, foreign_key: :engineer_id, dependent: :destroy
    has_many :services, through: :service_engineers
    has_many :monitoring, class_name: "::Service", inverse_of: :engineer, foreign_key: :engineer_id
    
    def full_name
       "#{first_name} #{last_name}" 
    end
end
