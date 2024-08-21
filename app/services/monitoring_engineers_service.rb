class MonitoringEngineersService
    def self.call(company_id, date = "08-19-2024")
        new.call(company_id, date)
    end

    def call(company_id, date)
        company = Company.includes(:schedules, [services: [:service_engineers, :engineers]]).find_by(id: company_id)

        return if company.nil? || company.services.empty?
        
        services_by_day = company.services.group_by { |service| service.date_format }
        schedules_by_week_number = company.schedules.group_by { |schedules| schedules.week_number }
        
        services_by_day.each do |key, values|
            services_by_day[key] = values.group_by { |service| service.hour_format }
        end
        
        service_date = Date.strptime(date, "%m-%d-%Y")
        
        (0..6).map do |wday|
            week_day = service_date + wday
            week_day_format = week_day.strftime("%m-%d-%Y")
            services_by_shift = services_by_day[week_day_format]
            
            next if services_by_shift.nil?
            
            hours = hours_range(schedules_by_week_number[week_day.wday][0])
            
            start_index = hours.each_with_index do |value, index|
                             break index if services_by_shift[value].present? && services_by_shift[value][0].service_engineers.present?
                          end
                          
            next if start_index.blank?
            
            results = { results: [], min_shift: 0 }
            
            # Initialize the recursion, we start with the values in the hour found, we save the shifts and service's ids
            services_by_shift[hours[start_index]][0].engineer_ids.each do |id|
                recursion_monitoring_engineers(hours, start_index + 1, id, services_by_shift, 
                                               { id => [services_by_shift[hours[start_index]][0].id], "shifts" => 1 }, results)
            end
            
            hours_to_engineers(results[:results], results[:min_shift], week_day_format)
        end
        
        assign_engineers_to_hours
    end
    
    def recursion_monitoring_engineers(hours, index, previous_id, data, monitoring, results)
        if hours[index].nil?
            results[:results] << monitoring if results[:min_shift].zero? || monitoring["shifts"] <= results[:min_shift]
            results[:min_shift] = monitoring["shifts"] if results[:min_shift].zero? || monitoring["shifts"] < results[:min_shift]
            
            return results
        end
        
        if data[hours[index]].nil? || data[hours[index]][0].service_engineers.empty?
            recursion_monitoring_engineers(hours, index + 1, previous_id, data, monitoring, results)
        else
            service = data[hours[index]][0]
            
            service.engineer_ids.each do |id|
                copy_monitoring = hash_deep_copy(monitoring)
                
                if previous_id == id
                    copy_monitoring[id] << service.id
                else
                    copy_monitoring["shifts"] += 1
                    copy_monitoring[id].nil? ? copy_monitoring[id] = [service.id] : copy_monitoring[id] << service.id
                end
                
                recursion_monitoring_engineers(hours, index + 1, id, data, copy_monitoring, results)
            end
        end
        
        results
    end
    
    def assign_engineers_to_hours
        shift_combination
    end
    
    def shift_combination
        # Generate all possible combinations based in the recursion result
        combinations = day_shifts.values[0].product(*day_shifts.values[1..-1])
        
        best_combination = nil
        minimum_difference = Float::INFINITY
        
        combinations.each do |combination|
          # Initialize the hash to get the sun of the engineers
          working_hours = Hash.new(0)
        
          # We sum all the hours for the workers based in the current combination
          combination.each do |shift|
            shift.each do |id, hours|
              working_hours[id] += hours.count
            end
          end
        
          # We calcualte the max difference along the hours
          max_hours = working_hours.values.max
          min_hours = working_hours.values.min
          difference = max_hours - min_hours
        
          # We save the combitaion if the difference is minimum
          if difference < minimum_difference
            minimum_difference = difference
            best_combination = combination
          end
        end
        
        best_combination
    end
    
    def hours_to_engineers(results, min_shift, date)
        day_shifts[date] = results.select { |result| result["shifts"] == min_shift }
                                  .map { |data| data.except("shifts") }
    end
    
    def hours_range(schedule)
        total_minutes = ((schedule.end_time_format) - schedule.start_time) / 60
            
        (0..total_minutes - 60).step(60).map { |minutes| (schedule.start_time + minutes * 60).strftime("%H:%M") }
    end
    
    def engineer_hours
        @engineer_hours ||= Engineer.all.pluck(:id).map { |id| [id, 0] }.to_h
    end
    
    def day_shifts
        @day_shifts ||= {}
    end
    
    def hash_deep_copy(o)
        Marshal.load(Marshal.dump(o))
    end
end