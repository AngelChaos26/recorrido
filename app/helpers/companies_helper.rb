# Helper for Companies controller and views
module CompaniesHelper
  include WeekFormatHelpers

  def render_services_table(day, company_schedules, company_services,
                            stimulus_action, ajax_url)
    content_tag(:table,
                class: 'min-w-full text-start text-sm font-light text-surface dark:text-white') do
      concat content_tag(:caption, '', class: 'caption-top')
      concat(
        content_tag(:thead,
                    class: 'border-b border-neutral-200 font-medium dark:border-white/10') do
          content_tag(:tr) do
            concat content_tag(:th, day_text_format(day),
                               class: 'px-6 py-4')
            enginners_header
          end
        end
      )
      concat(
        content_tag(:tbody) do
          company_schedules[day.wday][0].hours_range.each do |hour|
            concat(
              content_tag(:tr,
                          class: 'border-b border-neutral-200 dark:border-white/10') do
                enginners_checkbox(company_services, hour, day,
                                   stimulus_action, ajax_url)
              end
            )
          end
        end
      )
    end
  end

  def engineers
    @engineers ||= Engineer.all
  end

  def enginners_header
    engineers.map do |engineer|
      concat content_tag(:th, engineer.full_name, class: 'px-6 py-4')
    end
  end

  def enginners_checkbox(services, hour, week, stimulus_action, ajax_url)
    week_value = week_value_format(week)
    tag_styles = 'whitespace-nowrap px-6 py-4'
    ajax_params = { day: week_value, hour: }
    service_engineers = {}

    if services[week_value].present? && services[week_value][hour].present?
      service_engineers =
        services[week_value][hour][0].service_engineers.group_by(&:engineer_id)
    end

    td_style = service_engineers.empty? ? 'bg-red-400' : 'bg-green-400'
    concat content_tag(:td, hour, class: "#{tag_styles} font-medium #{td_style}")

    engineers.map do |engineer|
      service_engineer = service_engineers[engineer.id]
      check_box_html =
        tailwind_checkbox('engineer', service_engineer.present? ? service_engineer[0].id : '',
                          service_engineer.present? ? true : false,
                          stimulus_action,
                          { params: ajax_params.merge!(engineer_id: engineer.id), url: ajax_url })

      concat content_tag(:td, check_box_html, class: tag_styles)
    end
  end

  def tailwind_checkbox(name, value, checked, stimulus_action, options)
    check_box_tag(name, value, checked, class: 'form-checkbox text-green-600 h-5 w-5',
                                        data: { action: stimulus_action,
                                                ajax_params: options[:params],
                                                ajax_url: options[:url] })
  end
end
