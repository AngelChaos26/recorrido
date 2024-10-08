require 'rails_helper'

RSpec.describe MonitoringEngineersService, type: :service do
  describe '#perform' do
    let(:company) { create(:company) }
    let(:engineer1) { create(:engineer, first_name: 'Benjamin') }
    let(:engineer2) { create(:engineer, first_name: 'Ernesto') }
    let(:engineer3) { create(:engineer, first_name: 'Barbara') }
    let(:beginning_of_week) { Time.zone.today.beginning_of_week }

    it 'does add the engineers based in the PDF example' do
      allow(CompanySchedulesService).to receive(:call).and_return(nil)
      allow_any_instance_of(Service::Engineer).to receive(:call_monitoring_engineer_service).and_return(nil)

      # Creates the schedules
      (0..6).each do |wday|
        start_time = wday.zero? || wday == 6 ? '10:00' : '19:00'
        create(:company_schedule, company_id: company.id, week_number: wday,
                                  start_time:, end_time: '00:00')
      end

      schedules = company.reload.schedules

      # Creates the records without associated a engineer directly with a service yet
      (0..6).each do |wday|
        week_day = beginning_of_week + wday

        schedules.find_by(week_number: week_day.wday).hours_range.each_with_index do |hour, index|
          monitoring_shift = DateTime.strptime("#{week_day.strftime('%m-%d-%Y')} #{hour}",
                                               '%m-%d-%Y %H:%M').to_i
          service = create(:service, :without_engineer, company_id: company.id,
                                                        monitoring_shift:)

          case wday
          when 0 then create(:service_engineer, service_id: service.id, engineer_id: engineer1.id)
          when 1 then [engineer1.id, engineer2.id, engineer3.id].each do |id|
                        create(:service_engineer, service_id: service.id, engineer_id: id)
                      end
          when 2 then [engineer2.id, engineer3.id].each do |id|
                        create(:service_engineer, service_id: service.id, engineer_id: id)
                      end
          when 3 then [engineer1.id, engineer2.id, engineer3.id].each do |id|
                        create(:service_engineer, service_id: service.id, engineer_id: id)
                      end
          when 4 then [engineer1.id, engineer2.id].each do |id|
                        create(:service_engineer, service_id: service.id, engineer_id: id)
                      end
          when 5
            if index <= 5
              create(:service_engineer, service_id: service.id, engineer_id: engineer1.id)
            elsif index >= 9
              if index <= 11
                create(:service_engineer, service_id: service.id,
                                          engineer_id: engineer2.id)
              end
              create(:service_engineer, service_id: service.id, engineer_id: engineer3.id)
            end
          when 6 then create(:service_engineer, service_id: service.id, engineer_id: engineer2.id)
          end
        end
      end

      expect(company.schedules.count).to eq(7)
      expect(company.reload.services.pluck(:engineer_id).compact).to be_empty

      described_class.call(company.id, beginning_of_week.strftime('%m-%d-%Y'))

      company.reload

      expect(company.services.pluck(:engineer_id).compact).not_to be_empty
      expect(company.services.where(engineer_id: nil).count).to   eq(3)

      # Monday, full for Benjamin
      services = company.services.by_range(beginning_of_week.beginning_of_day,
                                           beginning_of_week.end_of_day)

      expect(services.map { |service| service.engineer.first_name }.uniq).to eq(['Benjamin'])

      # Thuesday, full for Benjamin
      services = company.services.by_range((beginning_of_week + 1).beginning_of_day,
                                           (beginning_of_week + 1).end_of_day)

      expect(services.map { |service| service.engineer.first_name }.uniq).to eq(['Benjamin'])

      # Wednesday, full for Barbara
      services = company.services.by_range((beginning_of_week + 2).beginning_of_day,
                                           (beginning_of_week + 2).end_of_day)

      expect(services.map { |service| service.engineer.first_name }.uniq).to eq(['Barbara'])

      # Thursday, full for Barbara
      services = company.services.by_range((beginning_of_week + 3).beginning_of_day,
                                           (beginning_of_week + 3).end_of_day)

      expect(services.map { |service| service.engineer.first_name }.uniq).to eq(['Barbara'])

      # Friday, full for Barbara
      services = company.services.by_range((beginning_of_week + 4).beginning_of_day,
                                           (beginning_of_week + 4).end_of_day)

      expect(services.map { |service| service.engineer.first_name }.uniq).to eq(['Ernesto'])

      # Saturday, Benjamin and Barbara, the nil represents those without assigned
      services = company.services.by_range((beginning_of_week + 5).beginning_of_day,
                                           (beginning_of_week + 5).end_of_day)

      expect(services.map do |service|
               service&.engineer&.first_name
             end.uniq).to eq(['Benjamin', nil, 'Barbara'])

      # Sunday, full for Ernesto
      services = company.services.by_range((beginning_of_week + 6).beginning_of_day,
                                           (beginning_of_week + 6).end_of_day)

      expect(services.map { |service| service.engineer.first_name }.uniq).to eq(['Ernesto'])

      expect(company.services.where(engineer_id: engineer1.id).count).to eq(16)
      expect(company.services.where(engineer_id: engineer2.id).count).to eq(19)
      expect(company.services.where(engineer_id: engineer3.id).count).to eq(15)
    end

    it 'does add the engineers based in new implementation without the min_shift' do
      allow(CompanySchedulesService).to receive(:call).and_return(nil)
      allow_any_instance_of(Service::Engineer).to receive(:call_monitoring_engineer_service).and_return(nil)

      # Creates the schedules
      (0..6).each do |wday|
        start_time = wday.zero? || wday == 6 ? '10:00' : '19:00'
        create(:company_schedule, company_id: company.id, week_number: wday,
                                  start_time:, end_time: '00:00')
      end

      schedules = company.reload.schedules

      # Creates the records without associated a engineer directly with a service yet
      (0..6).each do |wday|
        week_day = beginning_of_week + wday

        schedules.find_by(week_number: week_day.wday).hours_range.each_with_index do |hour, _index|
          monitoring_shift = DateTime.strptime("#{week_day.strftime('%m-%d-%Y')} #{hour}",
                                               '%m-%d-%Y %H:%M').to_i
          service = create(:service, :without_engineer, company_id: company.id,
                                                        monitoring_shift:)

          case wday
          when 0 then [engineer1.id, engineer2.id].each do |id|
                        create(:service_engineer, service_id: service.id, engineer_id: id)
                      end
          when 1 then [engineer2.id, engineer3.id].each do |id|
                        create(:service_engineer, service_id: service.id, engineer_id: id)
                      end
          end
        end
      end

      expect(company.schedules.count).to eq(7)
      expect(company.reload.services.pluck(:engineer_id).compact).to be_empty

      described_class.call(company.id, beginning_of_week.strftime('%m-%d-%Y'))

      company.reload

      expect(company.services.pluck(:engineer_id).compact).not_to be_empty
      expect(company.services.where(engineer_id: nil).count).to   eq(43)

      # Monday, full for Benjamin
      services = company.services.by_range(beginning_of_week.beginning_of_day,
                                           beginning_of_week.end_of_day)

      expect(services.map do |service|
               service.engineer.first_name
             end.uniq).to eq(%w[Ernesto Benjamin])

      # Thuesday, full for Benjamin
      services = company.services.by_range((beginning_of_week + 1).beginning_of_day,
                                           (beginning_of_week + 1).end_of_day)

      expect(services.map do |service|
               service.engineer.first_name
             end.uniq).to eq(%w[Barbara Ernesto])

      expect(company.services.where(engineer_id: engineer1.id).count).to eq(3)
      expect(company.services.where(engineer_id: engineer2.id).count).to eq(3)
      expect(company.services.where(engineer_id: engineer3.id).count).to eq(4)
    end
  end
end
