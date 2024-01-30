class Admin::ErrorsController < AdminController
  before_action :set_error, only: %i[show update]

  def index
    ErrorsService::Error.unresolved
                        .joins(:occurrences)
                        .select("errors.*, MAX(error_occurrences.created_at) AS recent_occurrence")
                        .group("errors.id")
                        .order("recent_occurrence DESC")
  end

  def show
  end

  def update
    @error.update!(error_params)
    redirect_to admin_errors_path, notice: "Error marked as resolved."
  end

  private

  def error_params
    params.require(:error).permit(:resolved_at)
  end

  def set_error
    @error = Error.find(params[:id])
  end
end