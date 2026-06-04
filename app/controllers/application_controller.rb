class ApplicationController < ActionController::Base
  before_action :set_current_user

  helper_method :current_user, :israel_logged_in?, :logged_in_as_israel?

  private

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) || User.find(User::PLAYER_ONE_ID)
  end

  def current_user
    @current_user
  end

  def israel_logged_in?
    current_user&.israel?
  end

  alias logged_in_as_israel? israel_logged_in?

  def require_israel!
    unless israel_logged_in?
      redirect_to login_path, alert: "Apenas o Israel pode fazer isso."
    end
  end
end
