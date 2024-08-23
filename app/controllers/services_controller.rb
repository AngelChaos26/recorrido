# Services controller for showing companies services based in a date and companies,
class ServicesController < ApplicationController
  include CompanyDependences

  def index
    companies
    company
    company_schedules
    company_services
    week
    weeks

    respond_to do |format|
      format.html { render 'index' }
      format.json { render json: { content: build_service_schedule } }
    end
  end

  private

  def build_service_schedule
    render_to_string(partial: 'services/index/service_schedule',
                     locals: { company:, week:, weeks:, company_schedules:,
                               company_services: },
                     layout: false, formats: :html)
  end

  def companies
    @companies ||= Company.includes(:schedules,
                                    [services: %i[service_engineers engineers
                                                  engineer]]).all
  end

  def company
    @company ||= company_id.zero? ? companies.first : companies.find_by(id: company_id)
  end

  def company_id
    @company_id ||= require_params[:company_id].present? ? require_params[:company_id].to_i : 0
  end

  def require_params
    params.permit(:id, :company_id, :week)
  end
end
