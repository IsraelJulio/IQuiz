class CardsController < ApplicationController
  before_action :require_israel!
  before_action :set_deck
  before_action :set_card, only: %i[edit update destroy]

  def new
    @card = @deck.cards.build
  end

  def create
    @card = @deck.cards.build(card_params)
    if @card.save
      redirect_to @deck, notice: "Card adicionado! 🃏"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @card.update(card_params)
      redirect_to @deck, notice: "Card atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
    redirect_to @deck, notice: "Card removido."
  end

  private

  def set_deck
    @deck = Deck.active.find(params[:deck_id])
  end

  def set_card
    @card = @deck.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:front, :back)
  end
end
