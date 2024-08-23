# Represents the hours assigned to a company for monitoring
class Company::Schedule < ApplicationRecord
  belongs_to :company, class_name: '::Company', inverse_of: :schedules

  validates :week_number, presence: true, numericality: true

  def end_time_format
    end_time.hour.zero? && end_time.min.zero? ? end_time + 1.day : end_time
  end

  def hours_range
    total_minutes = (end_time_format - start_time) / 60

    (0..total_minutes - 60).step(60).map do |minutes|
      (start_time + minutes * 60).strftime('%H:%M')
    end
  end
end
