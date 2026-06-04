class SessionsController < ApplicationController
  def new
    redirect_to root_path if israel_logged_in?
  end

  def create
    user = User.authenticate(params[:password])
    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bem-vindo, Israel! 👋"
    else
      flash.now[:alert] = "Senha incorreta."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Até logo! Você está jogando como Player One."
  end
end
