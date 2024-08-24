# Helper for Services controller and views
module ServicesHelper
  include WeekFormatHelpers

  def render_engineer_table(engineer_total_services)
    content_tag(:table,
                class: 'min-w-full text-start text-sm font-light text-surface dark:text-white') do
      concat content_tag(:caption, '', class: 'caption-top')
      concat(
        content_tag(:thead,
                    class: 'border-b border-neutral-200 font-medium dark:border-white/10') do
          content_tag(:tr) do
            concat content_tag(:th, 'Ingenieros', class: 'px-6 py-4')
          end
        end
      )
      concat(
        content_tag(:tbody) do
          engineer_total_services.each do |key, value|
            next if key.nil?

            concat(
              content_tag(:tr,
                          class: 'border-b border-neutral-200 dark:border-white/10') do
                concat content_tag(:td, engineers_by_id[key][0].full_name,
                                   class: 'whitespace-nowrap px-6 py-4 bg-cyan-200')
                concat content_tag(:td, value.count,
                                   class: 'whitespace-nowrap px-6 py-4 font-medium')
              end
            )
          end
        end
      )
    end
  end

  def render_schedule_table(company, day, company_schedules, company_services)
    content_tag(:table,
                class: 'min-w-full text-start text-sm font-light text-surface dark:text-white') do
      concat content_tag(:caption, '', class: 'caption-top')
      concat(
        content_tag(:thead,
                    class: 'border-b border-neutral-200 font-medium dark:border-white/10') do
          content_tag(:tr) do
            concat content_tag(:th, company.name,
                               class: 'px-6 py-4')
            concat content_tag(:th, day_text_format(day),
                               class: 'px-6 py-4')
          end
        end
      )
      concat(
        content_tag(:tbody) do
          company_schedules[day.wday][0].hours_range.each do |hour|
            concat(
              content_tag(:tr,
                          class: 'border-b border-neutral-200 dark:border-white/10') do
                assigned_engineer(company_services, hour, day)
              end
            )
          end
        end
      )
    end
  end

  def engineers_by_id
    @engineers_by_id ||= Engineer.all.group_by(&:id)
  end

  def assigned_engineer(services, hour, week)
    hour_styles = 'whitespace-nowrap px-6 py-4 font-medium bg-red-400'
    content_styles = 'whitespace-nowrap px-6 py-4'
    text = ''
    week_value = week_value_format(week)

    if engineer_assigned?(services[week_value], hour)
      hour_styles = 'whitespace-nowrap px-6 py-4 font-medium bg-green-400'
      content_styles = 'whitespace-nowrap px-6 py-4 bg-cyan-200'
      text = services[week_value][hour][0].engineer.full_name
    end

    concat content_tag(:td, hour, class: hour_styles)
    concat content_tag(:td, text, class: content_styles)
  end

  def engineer_assigned?(services, hour)
    services.present? && services[hour].present? && services[hour][0].engineer.present?
  end
end
