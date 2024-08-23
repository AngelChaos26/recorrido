# Service responsable for selecting the best combination of engineers assigned
#   to a specific hour in the calendar
class MonitoringEngineersService
  def self.call(company_id, date)
    new.call(company_id, date)
  end

  def call(company_id, date)
    company = Company.includes(:schedules,
                               [services: %i[service_engineers
                                             engineers]]).find_by(id: company_id)

    return if company.nil? || company.services.empty?

    # Define the services as a hash with the dates as keys
    # Example: { ""08-19-2024": [], "08-20-2024: [] ... }
    services_by_day = company.services_by_day
    # Redefine the services as a hash with the dates and hours as keys
    # Example: { "08-19-2024": [{ "17:00": [], "18:00": [] ...}], "08-20-2024: [{ "17:00": [] }]}
    services_by_day.each do |key, values|
      services_by_day[key] = values.group_by(&:hour_format)
    end
    # Define the schedules as a hash with the week_number as key
    schedules_by_week_number = company.schedules_by_week_number

    # We set the date given to the start of the week
    service_date = Date.strptime(date, '%m-%d-%Y').beginning_of_week

    # This number matchs with the wday given by the class Date, the same numbers we use for
    #   saving the week_number in Company::Schedule
    (0..6).map do |wday|
      week_day = service_date + wday
      week_day_format = week_day.strftime('%m-%d-%Y')
      services_by_shift = services_by_day[week_day_format]

      next if services_by_shift.nil?

      # Returns the range of hours provided by the schedule
      hours = schedules_by_week_number[week_day.wday][0].hours_range

      # Checks for a valid hour service in case the first hours have no engineers associated to them
      start_index = hours.each_with_index do |val, index|
        if services_by_shift[val].present? && services_by_shift[val][0].service_engineers.present?
          break index
        end
      end

      # If start_index is nil, it means could be services records, but without
      #     engineers associated we finish the service
      next if start_index.blank?

      results = { results: [], min_shift: 0 }

      # Initialize the recursion, we start with the values in the hour found,
      #     we save the shifts and service's ids
      services_by_shift[hours[start_index]][0].service_engineers.each do |service_engineer|
        engineer_id = service_engineer.engineer_id
        recursion_monitoring_engineers(hours, start_index + 1, engineer_id, services_by_shift,
                                       { engineer_id => [service_engineer.id], 'shifts' => 1 },
                                       results)
      end

      # We save the combinations with the minimum of shifts
      hours_to_engineers(results[:results], results[:min_shift],
                         week_day_format)
    end

    assign_engineers_to_hours(company, service_date)
  end

  # rubocop:disable Metrics/ParameterLists
  def recursion_monitoring_engineers(hours, index, previous_id, data,
                                     monitoring, results)
    # If the hours are finishid, we save the information if this is smaller
    #   that the current min_shift
    if hours[index].nil?
      if results[:min_shift].zero? || monitoring['shifts'] <= results[:min_shift]
        results[:results] << monitoring
      end
      if results[:min_shift].zero? || monitoring['shifts'] < results[:min_shift]
        results[:min_shift] =
          monitoring['shifts']
      end

      return results
    end

    # If no service_engineers associated, then we move to the next hour witout shift,
    #   as we can find the same engineer later
    if data[hours[index]].nil? || data[hours[index]][0].service_engineers.empty?
      recursion_monitoring_engineers(hours, index + 1, previous_id, data,
                                     monitoring, results)
    else
      service = data[hours[index]][0]

      service.service_engineers.each do |service_engineer|
        copy_monitoring = hash_deep_copy(monitoring)
        # Checking the engineer_id
        id = service_engineer.engineer_id

        # If its the same engineer that in the previous hour, we do not increase the shift,
        #   otherwise we increase it
        if previous_id == id
          copy_monitoring[id] << service_engineer.id
        else
          copy_monitoring['shifts'] += 1
          if copy_monitoring[id].nil?
            copy_monitoring[id] =
              [service_engineer.id]
          else
            copy_monitoring[id] << service_engineer.id
          end
        end

        recursion_monitoring_engineers(hours, index + 1, id, data,
                                       copy_monitoring, results)
      end
    end

    results
  end
  # rubocop:enable Metrics/ParameterLists

  def assign_engineers_to_hours(company, date)
    # We get all the service_engineer's ids grouped by engineer_ids,
    #   giving us the best option per service
    service_engineer_ids = reduce_engineer_combinations(shift_combination)
    service_ids = []

    # Updates the Service::Engineer by the engineer_id key in hash,
    #   we save the services affected in an array
    service_engineer_ids.each do |key, values|
      service_engineers = Service::Engineer.includes(:service).where(id: values)

      service_engineers.each do |service_engineer|
        service_engineer.service.update!(engineer_id: key)
      end
      service_ids << service_engineers.pluck(:service_id)
    end

    # We get the service's ids associated to the company into the range of the date, we are going to
    #   set the engineer(engineer_id) to nil of those services not monitored
    company.services.by_range(date.beginning_of_day,
                              date.end_of_week.end_of_day).where.not(id: service_ids)
           .find_each { |service| service.update!(engineer_id: nil) }
  end

  def shift_combination
    # Generate all possible combinations based in the recursion result
    combinations = day_shifts.values[0].product(*day_shifts.values[1..])

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
    day_shifts[date] = results.select { |result| result['shifts'] == min_shift }
                              .map { |data| data.except('shifts') }
  end

  def day_shifts
    @day_shifts ||= {}
  end

  def reduce_engineer_combinations(combinations)
    combinations.each_with_object({}) do |hash, acc|
      hash.each do |key, value|
        acc[key] ||= []
        acc[key] += value
      end
    end
  end

  def hash_deep_copy(hash)
    Marshal.load(Marshal.dump(hash))
  end
end
