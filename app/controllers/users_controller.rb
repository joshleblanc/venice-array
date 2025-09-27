class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      start_new_session_for(@user)
      redirect_to after_authentication_url, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = Current.user
    authorize @user
  end

  def update
    @user = Current.user
    authorize @user
    if @user.update(user_params)
      redirect_to after_authentication_url, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def user_params
      permitted = params.require(:user).permit(:email_address, :password, :password_confirmation, :venice_api_key)
      if permitted[:password].blank?
        permitted.delete(:password)
        permitted.delete(:password_confirmation)
      end
      permitted
    end
end
