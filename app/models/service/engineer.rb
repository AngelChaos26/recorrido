# Represents the services that the engineer is monitoring
class Service::Engineer < ApplicationRecord
  belongs_to :service, class_name: '::Service',
                       inverse_of: :service_engineers
  belongs_to :engineer, class_name: '::Engineer',
                        inverse_of: :service_engineers

  after_create :call_monitoring_engineer_service
  after_destroy :call_monitoring_engineer_service

  private

  def call_monitoring_engineer_service
    MonitoringEngineersJob.perform_later(service_id)
  end
end
