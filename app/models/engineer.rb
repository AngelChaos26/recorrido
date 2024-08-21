class Engineer < ApplicationRecord
    has_many :service_engineers, class_name: "Service::Engineer", inverse_of: :engineer, foreign_key: :engineer_id
    has_many :services, through: :service_engineers
end
