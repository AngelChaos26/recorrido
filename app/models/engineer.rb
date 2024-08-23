# Represents the engineer responsable for monitoring
class Engineer < ApplicationRecord
  has_many :service_engineers, class_name: 'Service::Engineer',
                               inverse_of: :engineer, dependent: :destroy
  has_many :services, through: :service_engineers

  def full_name
    "#{first_name} #{last_name}"
  end
end
