module WeekFormatHelpers
    extend ActiveSupport::Concern
  
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