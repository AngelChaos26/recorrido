module CompanyDependences
    extend ActiveSupport::Concern
    
    def company_schedules
        @company_schedules ||= company.schedules_by_week_number
    end
    
    def company_services
        @company_services ||= begin
            services_by_day = company.services
                                     .group_by { |service| service.date_format }
            services_by_day.map do |key, values|
                [key, values.group_by { |service| service.hour_format }]
            end.to_h
        end
    end
    
    def week
        @week ||= require_params[:week].present? ? Date.strptime(require_params[:week], "%m-%d-%Y") : Date.today.beginning_of_week
    end
    
    def weeks
        @weeks ||= begin
            current_date = Date.today.beginning_of_week
            
            (0..4).map { |value| current_date + value.weeks }
        end
    end
end