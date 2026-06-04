class CardAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :card
  belongs_to :game_session

  validates :direction, inclusion: { in: %w[front back] }
  validates :correct, inclusion: { in: [true, false] }
end
