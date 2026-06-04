require "csv"

class DecksController < ApplicationController
  before_action :set_deck,       only: %i[show edit update destroy import_form import_process]
  before_action :require_israel!, only: %i[new create edit update destroy import_form import_process import_new_form import_new_process]

  def index
    @decks = Deck.active.order(created_at: :desc)
  end

  def show
    @cards = @deck.cards.order(:id)
  end

  def new
    @deck = Deck.new
  end

  def create
    @deck = Deck.new(deck_params)
    if @deck.save
      redirect_to @deck, notice: "Lista criada com sucesso! 🎉"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @deck.update(deck_params)
      redirect_to @deck, notice: "Lista atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deck.soft_delete!
    redirect_to decks_path, notice: "Lista removida."
  end

  # Import cards into existing deck
  def import_form; end

  def import_process
    result = process_csv(params[:csv_file], @deck)
    if result[:error]
      flash.now[:alert] = result[:error]
      render :import_form, status: :unprocessable_entity
    else
      if result[:imported] > 0 && !current_user.has_achievement?("importer")
        AchievementService.award_importer!(current_user)
      end
      redirect_to @deck, notice: "#{result[:imported]} card(s) importado(s) com sucesso! 📥"
    end
  end

  # Import into a brand new deck
  def import_new_form
    @deck = Deck.new
  end

  def import_new_process
    @deck = Deck.new(name: params[:deck_name], description: params[:deck_description])
    unless @deck.save
      flash.now[:alert] = @deck.errors.full_messages.join(", ")
      render :import_new_form, status: :unprocessable_entity and return
    end

    result = process_csv(params[:csv_file], @deck)
    if result[:error]
      @deck.destroy
      flash.now[:alert] = result[:error]
      render :import_new_form, status: :unprocessable_entity
    else
      if result[:imported] > 0 && !current_user.has_achievement?("importer")
        AchievementService.award_importer!(current_user)
      end
      redirect_to @deck, notice: "#{result[:imported]} card(s) importado(s) e nova lista criada! 📥"
    end
  end

  private

  def set_deck
    @deck = Deck.active.find(params[:id])
  end

  def deck_params
    params.require(:deck).permit(:name, :description)
  end

  def process_csv(file, deck)
    return { error: "Nenhum arquivo enviado." } unless file.present?

    imported = 0
    begin
      content = file.read.force_encoding("UTF-8")
      CSV.parse(content, liberal_parsing: true) do |row|
        front = row[0]&.strip
        back  = row[1]&.strip
        next if front.blank? || back.blank?

        deck.cards.create!(front: front, back: back)
        imported += 1
      end
    rescue CSV::MalformedCSVError => e
      return { error: "Erro ao processar CSV: #{e.message}" }
    end

    { imported: imported }
  end
end
