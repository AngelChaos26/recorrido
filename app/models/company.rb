# Represents the company that receives the services of monitoring
class Company < ApplicationRecord
  has_many :schedules, class_name: 'Company::Schedule', inverse_of: :company, dependent: :destroy
  has_many :services, class_name: 'Service', inverse_of: :company, dependent: :destroy

  after_create :call_company_schedule_service

  validates :name, uniqueness: true

  def schedules_by_week_number
    schedules.group_by(&:week_number)
  end

  def services_by_day
    services.group_by(&:date_format)
  end

  private

  def call_company_schedule_service
    CompanySchedulesJob.perform_now(id)
  end
end
