# Companies controller for editing and updating companies services based in a date,
#   creates or destroy a service_engineer
class CompaniesController < ApplicationController
  include CompanyDependences

  before_action :redirect_root_path_if_needed, only: :edit

  def edit
    company
    company_schedules
    company_services
    week

    render 'edit'
  end

  def update
    if service_engineer_id.zero?
      service = find_service

      if service.nil?
        service = company.services.new(monitoring_shift:)

        unless service.save!
          flash[:alert] = 'No se pudo asociar el Servicio.'
          redirect_to services_path
        end
      end

      service.reload.service_engineers.create!(engineer_id:)
    else
      Service::Engineer.find_by(id: service_engineer_id).destroy!
    end

    respond_to do |format|
      format.json do
        render json: { content: build_service_schedule,
                       container: require_params[:day] }
      end
    end
  end

  private

  def build_service_schedule
    render_to_string(partial: 'companies/edit/service_week',
                     locals: { day: Date.strptime(require_params[:day], '%m-%d-%Y'),
                               company_schedules:,
                               company_services: },
                     layout: false, formats: :html)
  end

  def find_service
    company.services.find_by(monitoring_shift:)
  end

  def company
    @company ||= Company.includes(:schedules,
                                  [services: %i[service_engineers
                                                engineers]]).find_by(id: company_id)
  end

  def monitoring_shift
    @monitoring_shift ||= DateTime.strptime(
      "#{require_params[:day]} #{require_params[:hour]}", '%m-%d-%Y %H:%M'
    ).to_i
  end

  def company_id
    @company_id ||= require_params[:id].to_i
  end

  def engineer_id
    @engineer_id ||= require_params[:engineer_id]
  end

  def service_engineer_id
    @service_engineer_id ||= require_params[:value].to_i
  end

  def require_params
    params.permit(:id, :week, :day, :hour, :engineer_id, :value)
  end

  def redirect_root_path_if_needed
    redirect_to services_path if company.nil? || !weeks.include?(week)
  end
end
