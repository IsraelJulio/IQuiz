class DashboardController < ApplicationController
  def index
    @sessions = filtered_sessions

    # Stats per direction
    @front_points   = current_user.points_for_direction("front")
    @back_points    = current_user.points_for_direction("back")
    @front_accuracy = current_user.accuracy_for_direction("front")
    @back_accuracy  = current_user.accuracy_for_direction("back")

    # Heatmap data: last 12 months
    since = 12.months.ago.beginning_of_day
    daily = GameSession.completed
                       .where(user: current_user)
                       .where("started_at >= ?", since)
                       .group("DATE(started_at AT TIME ZONE 'America/Sao_Paulo')")
                       .select("DATE(started_at AT TIME ZONE 'America/Sao_Paulo') AS day, COUNT(*) AS session_count, AVG(CASE WHEN cards_total > 0 THEN cards_correct::float/cards_total ELSE 0 END)*100 AS avg_accuracy")

    @heatmap = daily.each_with_object({}) do |row, h|
      h[row.day.to_s] = { count: row.session_count.to_i, accuracy: row.avg_accuracy.to_f.round(1) }
    end

    @achievements      = Achievement.all.order(:id)
    @user_achievements = current_user.user_achievements.index_by(&:achievement_id)
    @goals             = Goal.where(user: current_user)
    @active_decks      = Deck.active.order(:name)

    # Filters state for re-render
    @filter_user      = params[:filter_user]
    @filter_deck      = params[:filter_deck]
    @filter_mode      = params[:filter_mode]
    @filter_direction = params[:filter_direction]
  end

  def day
    date = Date.parse(params[:date]) rescue Date.current
    @sessions = GameSession.completed
                           .where(user: current_user)
                           .where("DATE(started_at AT TIME ZONE 'America/Sao_Paulo') = ?", date)
                           .order(started_at: :desc)
    @date = date

    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("day-detail", partial: "dashboard/day_detail",
                                                                locals: { sessions: @sessions, date: @date })
      end
    end
  end

  private

  def filtered_sessions
    scope = GameSession.completed.includes(:user, :deck).order(started_at: :desc)

    # Show both users to anyone for the leaderboard
    scope = scope.where(user_id: params[:filter_user]) if params[:filter_user].present?
    scope = scope.where(deck_id: params[:filter_deck]) if params[:filter_deck].present?
    scope = scope.where(game_mode: params[:filter_mode]) if params[:filter_mode].present?
    scope = scope.where(direction: params[:filter_direction]) if params[:filter_direction].present?

    scope.limit(200)
  end
end
