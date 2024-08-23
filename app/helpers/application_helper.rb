module ApplicationHelper
    def render_schedule_table(company, day, company_schedules, company_services)
        content_tag(:table, class: "min-w-full text-start text-sm font-light text-surface dark:text-white") do
            concat content_tag(:caption, "", class: "caption-top")
            concat(
                content_tag(:thead, class: "border-b border-neutral-200 font-medium dark:border-white/10") do
                    content_tag(:tr) do
                        concat content_tag(:th, company.name, class: "px-6 py-4")
                        concat content_tag(:th, day_text_format(day), class: "px-6 py-4")
                    end
                end
            )
            concat(
                content_tag(:tbody) do
                    company_schedules[day.wday][0].hours_range.each do |hour|
                        concat(
                            content_tag(:tr, class: "border-b border-neutral-200 dark:border-white/10") do
                                assigned_engineer(company_services, hour, day)
                            end
                        )
                    end
                end
            )
        end
    end
    
    def render_services_table(day, company_schedules, company_services, stimulus_action, ajax_url)
        content_tag(:table, class: "min-w-full text-start text-sm font-light text-surface dark:text-white") do
            concat content_tag(:caption, "", class: "caption-top")
            concat(
                content_tag(:thead, class: "border-b border-neutral-200 font-medium dark:border-white/10") do
                    content_tag(:tr) do
                        concat content_tag(:th, day_text_format(day), class: "px-6 py-4")
                        enginners_header
                    end
                end
            )
            concat(
                content_tag(:tbody) do
                    company_schedules[day.wday][0].hours_range.each do |hour|
                        concat(
                            content_tag(:tr, class: "border-b border-neutral-200 dark:border-white/10") do
                                enginners_checkbox(company_services, hour, day, stimulus_action, ajax_url)
                            end
                        )
                    end
                end
            )
        end
    end
  
    def assigned_engineer(services, hour, week)
        week_value = week_value_format(week)
        
        if services[week_value].nil? || services[week_value][hour].nil? || services[week_value][hour][0].engineer.nil?
            concat content_tag(:td, hour, class: "whitespace-nowrap px-6 py-4 font-medium bg-red-400")
            concat content_tag(:td, "",   class: "whitespace-nowrap px-6 py-4") 
        else
            concat content_tag(:td, hour, class: "whitespace-nowrap px-6 py-4 font-medium bg-green-400")
            concat content_tag(:td, services[week_value][hour][0].engineer.full_name, class: "whitespace-nowrap px-6 py-4 bg-cyan-200") 
        end
    end
    
    def engineers
        @engineers ||= Engineer.all
    end
    
    def enginners_header
        engineers.map { |engineer| concat content_tag(:th, engineer.full_name, class: "px-6 py-4") }
    end
    
    def enginners_checkbox(services, hour, week, stimulus_action, ajax_url)
        week_value = week_value_format(week)
        ajax_params = { day: week_value, hour: hour }
        service_engineers = {}
        
        if services[week_value].present? && services[week_value][hour].present?
            service_engineers = 
                services[week_value][hour][0].service_engineers.group_by { |service_engineer| service_engineer.engineer_id }
        end
        
        concat content_tag(:td, hour, class: "whitespace-nowrap px-6 py-4 font-medium #{service_engineers.empty? ? "bg-red-400" : "bg-green-400"}")
        
        engineers.map do |engineer|
            check_box_html = tailwind_checkbox("engineer", service_engineers[engineer.id].present? ? service_engineers[engineer.id][0].id : "", 
                                                service_engineers[engineer.id].present? ? true : false, 
                                                stimulus_action, ajax_params.merge!(engineer_id: engineer.id), ajax_url)
                                            
            concat content_tag(:td, check_box_html, class: "whitespace-nowrap px-6 py-4")
        end
    end
    
    def tailwind_checkbox(name, value, checked, stimulus_action, ajax_params, ajax_url)
        check_box_tag(name, value, checked, class: "form-checkbox text-green-600 h-5 w-5", 
                      data: { action: stimulus_action, ajax_params: ajax_params, ajax_url: ajax_url })
    end
    
    def week_select_option(weeks)
        weeks.map do |week|
            [week_value_format(week), week_text_format(week)]
        end.to_h
    end
    
    def week_text_format(week)
        "Semana #{week.cweek} del #{week.year}"
    end
    
    def week_value_format(week)
        week.strftime("%m-%d-%Y")
    end
    
    def day_text_format(date)
        date.strftime("%A #{date.day.ordinalize} %B")
    end
end
