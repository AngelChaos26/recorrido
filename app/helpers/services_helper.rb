module ServicesHelper
    include WeekFormatHelpers
    
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
end