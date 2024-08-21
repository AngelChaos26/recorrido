# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

ActiveRecord::Base.transaction do
    company = Company.find_or_create_by!(name: "Recorrido")

    (0..6).each do |wday|
        start_time = wday.zero? || wday == 6 ? "10:00" : "19:00"
        Company::Schedule.find_or_create_by!(company_id: company.id, week_number: wday, start_time: start_time, end_time: "00:00")
    end
    
    engineer1 = Engineer.find_or_create_by!(first_name: "Benjamin", last_name: "Gonzales")
    engineer2 = Engineer.find_or_create_by!(first_name: "Barbara", last_name: "Gomez")
    engineer3 = Engineer.find_or_create_by!(first_name: "Ernesto", last_name: "Tapia")
    
    schedules = company.schedules
    
    beginning_of_week = Date.today.beginning_of_week
    
    (0..6).each do |wday|
        week_day = beginning_of_week + wday
        week_day_schedule = schedules.find_by(week_number: week_day.wday)
        total_minutes = ((week_day_schedule.end_time + 1.day) - week_day_schedule.start_time) / 60
        
        (0..total_minutes - 60).step(60) do |minutes|
            time = week_day_schedule.start_time + minutes * 60
            monitoring_shift = DateTime.strptime("#{week_day.strftime("%m-%d-%Y")} #{time.strftime("%H:%M")}", '%m-%d-%Y %H:%M').to_i
        
            service = Service.find_or_create_by!(company_id: company.id, monitoring_shift: monitoring_shift)
            
            case wday
            when 0 then service.service_engineers.find_or_create_by!(engineer_id: engineer1.id)
            when 1 then [engineer1.id, engineer2.id, engineer3.id].each { |id| service.service_engineers.find_or_create_by!(engineer_id: id) }
            when 2 then [engineer2.id, engineer3.id].each { |id| service.service_engineers.find_or_create_by!(engineer_id: id) }
            when 3 then [engineer1.id, engineer2.id, engineer3.id].each { |id| service.service_engineers.find_or_create_by!(engineer_id: id) }
            when 4 then [engineer1.id, engineer2.id].each { |id| service.service_engineers.find_or_create_by!(engineer_id: id) }
            when 5 then
                if minutes <= 240
                    service.service_engineers.find_or_create_by!(engineer_id: engineer1.id)
                elsif minutes >= 480
                    service.service_engineers.find_or_create_by!(engineer_id: engineer2.id) if minutes <= 600
                    service.service_engineers.find_or_create_by!(engineer_id: engineer3.id)
                end
            when 6 then service.service_engineers.find_or_create_by!(engineer_id: engineer2.id)
            end
        end
    end
end
    
