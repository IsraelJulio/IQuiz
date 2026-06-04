class SpacedRepetitionService
  def initialize(user, direction, deck: nil)
    @user      = user
    @direction = direction
    @deck      = deck
  end

  # Returns shuffled array of card_ids that the user has errors on,
  # ordered by error rate desc with recency tiebreak.
  def card_ids
    cards_with_errors.shuffle
  end

  private

  def cards_with_errors
    scope = if @deck
              Card.where(deck: @deck)
            else
              Card.joins(:deck).where(decks: { deleted_at: nil })
            end

    attempts = CardAttempt.where(user: @user, direction: @direction)
                          .where(card_id: scope.select(:id))

    # Group by card_id
    by_card = attempts.group_by(&:card_id)

    # Keep only cards that have at least one error
    errored = by_card.select { |_, ats| ats.any? { |a| !a.correct } }

    # Sort by error_rate desc, then most-recent-error desc
    sorted = errored.sort_by do |card_id, ats|
      total      = ats.count.to_f
      errors     = ats.count { |a| !a.correct }
      error_rate = errors / total
      last_error = ats.select { |a| !a.correct }.map(&:created_at).max

      [-error_rate, -(last_error&.to_i || 0)]
    end

    sorted.map(&:first)
  end
end
