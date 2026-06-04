class User < ApplicationRecord
  has_many :game_sessions, dependent: :destroy
  has_many :card_attempts,  dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  has_many :goals, dependent: :destroy

  PLAYER_ONE_ID = 1
  ISRAEL_ID     = 2
  ISRAEL_PASSWORD = "123"

  scope :player_one, -> { find(PLAYER_ONE_ID) }
  scope :israel,     -> { find(ISRAEL_ID) }

  def self.authenticate(password)
    password == ISRAEL_PASSWORD ? find(ISRAEL_ID) : nil
  end

  def israel?
    is_israel
  end

  def total_points
    game_sessions.completed.sum(:total_points).to_f
  end

  def overall_accuracy
    total = card_attempts.count
    return 0.0 if total.zero?
    (card_attempts.where(correct: true).count.to_f / total * 100).round(1)
  end

  def accuracy_for_direction(direction)
    attempts = card_attempts.where(direction: direction)
    return 0.0 if attempts.empty?
    (attempts.where(correct: true).count.to_f / attempts.count * 100).round(1)
  end

  def points_for_direction(direction)
    game_sessions.completed.where(direction: direction).sum(:total_points).to_f
  end

  def has_achievement?(key)
    achievements.exists?(key: key)
  end
end
