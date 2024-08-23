class Service::Engineer < ApplicationRecord
    belongs_to :service, class_name: "::Service", inverse_of: :service_engineers, foreign_key: :service_id
    belongs_to :engineer, class_name: "::Engineer", inverse_of: :service_engineers, foreign_key: :engineer_id
    
    after_create :call_monitoring_engineer_service
    after_destroy :call_monitoring_engineer_service
    
    private
    
    def call_monitoring_engineer_service
        MonitoringEngineersJob.perform_now(self.reload.service_id)
    end
end
