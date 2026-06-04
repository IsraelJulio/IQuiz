class Deck < ApplicationRecord
  has_many :cards, dependent: :destroy
  has_many :game_sessions

  scope :active, -> { where(deleted_at: nil) }

  validates :name, presence: true

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def deleted?
    deleted_at.present?
  end

  def card_count
    cards.count
  end
end
