# Concern for companies and services controller and views, adding dependences
module CompanyDependences
  extend ActiveSupport::Concern

  def company_schedules
    @company_schedules ||= company.schedules_by_week_number
  end

  def company_services
    @company_services ||= begin
      services_by_day = company.services
                               .group_by(&:date_format)
      services_by_day.transform_values do |values|
        values.group_by(&:hour_format)
      end
    end
  end

  def week
    @week ||= if require_params[:week].present?
                Date.strptime(
                  require_params[:week], '%m-%d-%Y'
                )
              else
                Time.zone.today.beginning_of_week
              end
  end

  def weeks
    @weeks ||= begin
      current_date = Time.zone.today.beginning_of_week

      (0..4).map { |value| current_date + value.weeks }
    end
  end
end
