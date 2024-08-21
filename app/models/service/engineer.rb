class Service::Engineer < ApplicationRecord
    belongs_to :service, class_name: "::Service", inverse_of: :service_engineers, foreign_key: :service_id
    belongs_to :engineer, class_name: "::Engineer", inverse_of: :service_engineers, foreign_key: :engineer_id
end
