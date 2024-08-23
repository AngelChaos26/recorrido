# Job responsable for calling service CompanySchedulesService
class CompanySchedulesJob < ApplicationJob
  queue_as :default

  def perform(company_id)
    CompanySchedulesService.call(company_id)
  end
end
