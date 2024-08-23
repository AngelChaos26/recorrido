# Service for adding hours automatically to a company
class CompanySchedulesService
  def self.call(company_id)
    new.call(company_id)
  end

  def call(company_id)
    company = Company.find_by(id: company_id)

    return if company.nil?

    (0..6).each do |wday|
      # Monday to Friday schedules as in the pdf
      start_time = wday.zero? || wday == 6 ? '10:00' : '19:00'
      Company::Schedule.find_or_create_by!(company_id: company.id,
                                           week_number: wday, start_time:, end_time: '00:00')
    end

    true
  end
end
