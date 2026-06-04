class GameSession < ApplicationRecord
  belongs_to :user
  belongs_to :deck, optional: true
  has_many   :card_attempts, dependent: :destroy

  MODES = %w[
    base spaced_list spaced_global
    base_written spaced_list_written spaced_global_written
  ].freeze

  DIRECTIONS = %w[front back].freeze

  scope :completed,    -> { where(status: "completed") }
  scope :in_progress,  -> { where(status: "in_progress") }

  validates :game_mode,  inclusion: { in: MODES }
  validates :direction,  inclusion: { in: DIRECTIONS }

  def completed?
    status == "completed"
  end

  def written?
    game_mode.include?("written")
  end

  def spaced?
    game_mode.include?("spaced")
  end

  def current_card
    return nil if current_card_index >= card_order.length
    Card.find_by(id: card_order[current_card_index])
  end

  def progress_pct
    return 100 if card_order.empty?
    (current_card_index.to_f / card_order.length * 100).round
  end

  def accuracy
    return 0.0 if cards_total.zero?
    (cards_correct.to_f / cards_total * 100).round(1)
  end

  def streak_multiplier
    base = case current_streak
           when 0..2 then 1.0
           when 3..4 then 1.5
           when 5..9 then 2.0
           else           3.0
           end
    anti_grind ? base / 2.0 : base
  end

  def base_points_per_card
    anti_grind ? 0.5 : 1.0
  end

  def record_answer!(card_id, correct)
    card = Card.find(card_id)

    if correct
      self.current_streak  += 1
      self.max_streak       = [max_streak, current_streak].max
      pts = base_points_per_card * streak_multiplier
      self.total_points    += pts
      self.cards_correct   += 1
    else
      self.current_streak = 0
    end

    self.cards_total        += 1
    self.current_card_index += 1

    if current_card_index >= card_order.length
      self.status       = "completed"
      self.completed_at = Time.current
    end

    save!

    CardAttempt.create!(
      user:         user,
      card:         card,
      game_session: self,
      direction:    direction,
      correct:      correct
    )
  end

  def mode_label
    {
      "base"                    => "Base",
      "spaced_list"             => "Spaced Repetition (Lista)",
      "spaced_global"           => "Spaced Repetition (Geral)",
      "base_written"            => "Base — Escrita",
      "spaced_list_written"     => "Spaced Repetition (Lista) — Escrita",
      "spaced_global_written"   => "Spaced Repetition (Geral) — Escrita",
    }[game_mode] || game_mode
  end

  def direction_label
    direction == "front" ? "Frente → Verso" : "Verso → Frente"
  end
end
