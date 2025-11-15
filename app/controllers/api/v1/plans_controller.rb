module Api
  module V1
    class PlansController < Api::V1::BaseController
      before_action :set_plan
      def create
        plan = Plan.new(create_plan_params)
        if plan.save
          render json: json_response(plan), status: :created
        else
          render json: { errors: plan.errors.full_messages }, status: :ok
        end
      end

      def index
        current_user.client? ? client_plans : coach_plans
      end

      def client_plans
        active_plans = @plans.where(status: [:created, :needs_resubmission])
        all_plans = @plans.where.not(status: :created)
        exercise_proof_submitted_this_week = @plans
                                              .where(wellness_pillar: "exercise")
                                              .where(status: :approved)
                                              .where("plans.created_at >= ?", 1.week.ago)
                                              .select { |plan| plan.proofs.attached? }
        render json: {
          exercise_proof_submitted_this_week: exercise_proof_submitted_this_week.present?,
          active_plans: active_plans.map { |plan| json_response(plan) },
          all_plans: all_plans.map { |plan| json_response(plan) }
        }, status: :ok
      end

      def coach_plans
        active_plans = @plans.where(status: [:pending])
        all_plans = @plans.where.not(status: :pending)
        render json: {
          active_plans: active_plans.map { |plan| json_response(plan) },
          all_plans: all_plans.map { |plan| json_response(plan) }
        }, status: :ok
      end

      def update
        @plan = @plans.find(params[:id])
        if @plan.update(plan_params)
          render json: json_response(@plan), status: :ok
        else
          render json: { errors: @plan.errors.full_messages }, status: :ok
        end
      end

      def clients
        render json: {
          clients: current_user.clients.map do |client|
            {
              id: client.id,
              name: client.full_name,
              email: client.email,
              profile_picture_url: client.profile_picture.attached? ? url_for(client.profile_picture) : nil
            }
          end
        }, status: :ok
      end

      private

      def json_response(plan)
        {
          id: plan.id,
          icon: Plan::ICONS[plan.wellness_pillar.to_s],
          wellness_pillar: plan.wellness_pillar,
          proof_urls: plan.proofs.map { |proof| url_for(proof) },
          status: plan.status,
          due_date: plan.duration&.strftime("%I:%M %p, %d %b"),
          client_submitted_at: plan.client_submitted_at&.strftime("%I:%M %p, %d %b"),
          proof_required: plan.proof_required?,
          details: plan.details,
          user_name: plan.user.full_name,
          resubmission_reason: plan.resubmission_reason,
          created_at: plan.created_at.strftime("%I:%M %p, %d %b")
        }
      end

      def set_plan
        @plans = if current_user.role == "coach"
                    Plan.joins(:user).where(users: { id: current_user.clients.ids }).order(created_at: :desc)
                  else
                    current_user.plans.order(created_at: :desc)
                  end
      end

      def plan_params
        params.require(:plan).permit(:status, :resubmission_reason, proofs: [])
      end

      def create_plan_params
        params.require(:plan).permit(:details, :wellness_pillar, :duration, :reminder_time, :user_id)
      end
    end
  end
end