class GoalsController < ApplicationController
  before_action :require_israel!
  before_action :set_goal, only: %i[edit update destroy]

  def new
    @goal  = Goal.new(user: current_user)
    @decks = Deck.active.order(:name)
  end

  def create
    @goal = Goal.new(goal_params.merge(user: current_user))
    if @goal.save
      redirect_to dashboard_path, notice: "Meta criada! 🎯"
    else
      @decks = Deck.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @decks = Deck.active.order(:name)
  end

  def update
    if @goal.update(goal_params)
      redirect_to dashboard_path, notice: "Meta atualizada."
    else
      @decks = Deck.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    redirect_to dashboard_path, notice: "Meta removida."
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(:deck_id, :target_percentage, :label)
  end
end
