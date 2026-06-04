class AchievementService
  def initialize(user, game_session)
    @user    = user
    @session = game_session
  end

  def check_and_award!
    newly_unlocked = []

    Achievement.all.each do |achievement|
      next if @user.user_achievements.exists?(achievement: achievement)
      next unless qualifies?(achievement.key)

      @user.user_achievements.create!(achievement: achievement, unlocked_at: Time.current)
      newly_unlocked << achievement
    end

    newly_unlocked
  end

  def self.award_importer!(user)
    achievement = Achievement.find_by(key: "importer")
    return unless achievement
    return if user.user_achievements.exists?(achievement: achievement)

    user.user_achievements.create!(achievement: achievement, unlocked_at: Time.current)
    achievement
  end

  private

  def qualifies?(key)
    case key
    when "first_game"
      GameSession.where(user: @user, status: "completed").count >= 1
    when "marathoner"
      seven_day_streak?
    when "perfection"
      @session.accuracy >= 100.0 && @session.cards_total.positive?
    when "centurion"
      @user.total_points >= 100
    when "legend"
      @user.total_points >= 1000
    when "unstoppable"
      @session.max_streak >= 10
    when "importer"
      false
    when "reviewer"
      @session.game_mode.include?("spaced")
    when "ambidextrous"
      GameSession.completed.where(user: @user, direction: "front").exists? &&
        GameSession.completed.where(user: @user, direction: "back").exists?
    when "explorer"
      GameSession.completed.where(user: @user).where.not(deck_id: nil)
                 .distinct.count(:deck_id) >= 5
    when "night_owl"
      @session.started_at&.hour.to_i.zero? || (@session.started_at&.hour.to_i || 0).between?(0, 3)
    when "goal_achieved"
      Goal.where(user: @user).any? { |g| g.achieved?(@user) }
    else
      false
    end
  end

  def seven_day_streak?
    dates = GameSession.completed
                       .where(user: @user)
                       .where("started_at >= ?", 7.days.ago.beginning_of_day)
                       .pluck(:started_at)
                       .map(&:to_date)
                       .uniq
    (0..6).all? { |i| dates.include?(Date.current - i) }
  end
end
