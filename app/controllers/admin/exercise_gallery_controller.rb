class Admin::ExerciseGalleryController < Admin::ApplicationController
  PLANS_PER_PAGE = 3

  def index
    @clients = User.clients
    client_id = params[:client_id]
    plans_scope = Plan.joins(:user)
                      .where(users: { id: @clients.ids })
                      .where(wellness_pillar: :exercise)
                      .where.not(proofs_attachments: { id: nil })
                      .includes(:user, proofs_attachments: :blob)
                      .order(updated_at: :desc)
    plans_scope = plans_scope.where(user_id: client_id) if client_id.present? && client_id != "all"

    grouped_weeks = plans_scope.group_by { |p| p.updated_at.beginning_of_week }.to_a
    page = (params[:page] || 1).to_i
    @grouped_plans = Kaminari.paginate_array(grouped_weeks).page(page).per(PLANS_PER_PAGE)
  end
end