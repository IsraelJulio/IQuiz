class GameSessionsController < ApplicationController
  before_action :set_session, only: %i[show answer]

  def new
    @decks     = Deck.active.order(:name)
    @deck      = Deck.active.find_by(id: params[:deck_id])
    @game_modes = GameSession::MODES
  end

  def create
    deck       = Deck.active.find_by(id: params[:deck_id])
    direction  = params[:direction].to_s
    game_mode  = params[:game_mode].to_s

    unless GameSession::MODES.include?(game_mode) && GameSession::DIRECTIONS.include?(direction)
      redirect_to new_game_session_path, alert: "Opções inválidas." and return
    end

    card_ids = build_card_ids(game_mode, direction, deck)

    if card_ids.empty?
      msg = game_mode.include?("spaced") ?
        "Nenhum card com erros encontrado para esse modo. Jogue primeiro no modo Base para acumular histórico!" :
        "Essa lista não tem cards. Adicione cards antes de jogar."
      redirect_to new_game_session_path(deck_id: deck&.id), alert: msg and return
    end

    anti_grind = deck ? anti_grind?(current_user, deck) : false

    gs = GameSession.create!(
      user:      current_user,
      deck:      deck,
      deck_name: deck&.name || "Geral",
      game_mode: game_mode,
      direction: direction,
      card_order: card_ids.shuffle,
      started_at: Time.current,
      anti_grind: anti_grind
    )

    redirect_to game_session_path(gs)
  end

  def show
    if @game_session.completed?
      @newly_unlocked = flash[:newly_unlocked]&.map { |id| Achievement.find_by(id: id) }&.compact || []
      render :complete
    end
  end

  def answer
    return redirect_to game_session_path(@game_session) if @game_session.completed?

    card_id = @game_session.card_order[@game_session.current_card_index]
    correct = params[:correct] == "true"

    @game_session.record_answer!(card_id, correct)

    if @game_session.completed?
      newly_unlocked = AchievementService.new(current_user, @game_session).check_and_award!
      flash[:newly_unlocked] = newly_unlocked.map(&:id) if newly_unlocked.any?
    end

    redirect_to game_session_path(@game_session)
  end

  private

  def set_session
    @game_session = GameSession.find(params[:id])
    unless @game_session.user == current_user
      redirect_to root_path, alert: "Sessão não encontrada." and return
    end
  end

  def build_card_ids(game_mode, direction, deck)
    case game_mode
    when "base", "base_written"
      deck ? deck.cards.pluck(:id) : []
    when "spaced_list", "spaced_list_written"
      return [] unless deck
      SpacedRepetitionService.new(current_user, direction, deck: deck).card_ids
    when "spaced_global", "spaced_global_written"
      SpacedRepetitionService.new(current_user, direction).card_ids
    else
      []
    end
  end

  def anti_grind?(user, deck)
    GameSession.where(user: user, deck: deck, status: "completed")
               .where("completed_at > ?", 3.hours.ago)
               .exists?
  end
end
