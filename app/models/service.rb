# Represents the date and hour that a engineer will be given a service of monitoring
class Service < ApplicationRecord
  has_many :service_engineers, class_name: '::Service::Engineer',
                               inverse_of: :service, dependent: :destroy
  has_many :engineers, through: :service_engineers

  belongs_to :company, class_name: 'Company', inverse_of: :services
  belongs_to :engineer, class_name: '::Engineer', optional: true

  scope :by_range, lambda { |from, to|
                     where("datetime(monitoring_shift, 'unixepoch') BETWEEN ? AND ?", from, to)
                   }

  def date_format
    Time.zone.at(monitoring_shift).strftime('%m-%d-%Y')
  end

  def hour_format
    Time.zone.at(monitoring_shift).strftime('%H:%M')
  end
end
