class Goal < ApplicationRecord
  belongs_to :user
  belongs_to :deck, optional: true

  validates :target_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

  def display_label
    return label if label.present?
    deck ? "#{target_percentage.to_i}% em #{deck.name}" : "#{target_percentage.to_i}% global"
  end

  def current_progress(user)
    attempts = if deck_id
                 CardAttempt.joins(:card).where(cards: { deck_id: deck_id }, user: user)
               else
                 CardAttempt.where(user: user)
               end

    return 0.0 if attempts.empty?
    (attempts.where(correct: true).count.to_f / attempts.count * 100).round(1)
  end

  def achieved?(user)
    current_progress(user) >= target_percentage.to_f
  end
end
