class Card < ApplicationRecord
  belongs_to :deck
  has_many :card_attempts, dependent: :destroy

  validates :front, :back, presence: true

  def error_rate(user, direction)
    attempts = card_attempts.where(user: user, direction: direction)
    return 0.0 if attempts.empty?
    attempts.where(correct: false).count.to_f / attempts.count
  end

  def last_error_at(user, direction)
    card_attempts.where(user: user, direction: direction, correct: false)
                 .maximum(:created_at)
  end

  def has_errors?(user, direction)
    card_attempts.where(user: user, direction: direction, correct: false).exists?
  end
end
