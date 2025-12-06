module Api
  module V1
    class ExerciseGalleryController < Api::V1::BaseController

      PLANS_PER_PAGE = 2

      def index
        plans_scope = if current_user.coach?
          coach_plans
        else
          user_plans
        end

        # Group by week start
        grouped_weeks = plans_scope.group_by { |p| p.updated_at.beginning_of_week }.to_a

        page = (params[:page] || 1).to_i
        paginated = Kaminari.paginate_array(grouped_weeks).page(page).per(PLANS_PER_PAGE)

        render json: {
          current_page: paginated.current_page,
          total_pages: paginated.total_pages,
          total_groups: paginated.count,
          groups: paginated.map { |week_start, plans| format_group(week_start, plans) }
        }
      end

      private

      def coach_plans
        clients = current_user.clients
        client_id = params[:client_id]

        scope = Plan.joins(:user)
                    .where(users: { id: clients.ids })
                    .where(wellness_pillar: :exercise)
                    .where.not(proofs_attachments: { id: nil })
                    .includes(:user, proofs_attachments: :blob)
                    .order(updated_at: :desc)

        scope = scope.where(user_id: client_id) if client_id.present? && client_id != "all"

        scope
      end

      def user_plans
        current_user.plans
                    .where(wellness_pillar: :exercise)
                    .where.not(proofs_attachments: { id: nil })
                    .includes(proofs_attachments: :blob)
                    .order(updated_at: :desc)
      end

      # Format each week group for JSON
      def format_group(week_start, plans)
        {
          week_start: week_start.strftime("%b %e, %Y"),
          plans: plans.map { |p| format_plan(p) }
        }
      end

      # Format each plan
      def format_plan(plan)
        {
          id: plan.id,
          updated_on: plan.updated_at.strftime("%b %e, %Y"),
          status: plan.status.humanize,
          proofs: plan.proofs.map { |proof| url_for(proof) }
        }
      end
    end
  end
end