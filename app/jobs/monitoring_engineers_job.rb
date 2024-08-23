# Job responsable for calling service MonitoringEngineersJob
class MonitoringEngineersJob < ApplicationJob
  queue_as :default

  def perform(service_id)
    service = Service.find_by(id: service_id)

    return if service.nil?

    MonitoringEngineersService.call(service.company_id, service.date_format)
  end
end
