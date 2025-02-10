class UsersController < ActionController::API
  def index
    users = User.all
    render json: users
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def show
    user_id = params[:id]
    if user = User.where(id: user_id).first
      render json: user
    else
      render json: { message: "User with ID #{user_id} not found" }, status: :not_found
    end
  end

  def update
    user_id = params[:id]
    if user = User.where(id: user_id).first
      user.update(user_params)
      render json: user
    else
      render json: { message: "User with ID #{user_id} not found" }, status: :not_found
    end
  end

  def destroy
    user_id = params[:id]
    if user = User.where(id: user_id).first
      user.destroy
      render json: { message: "User with ID #{user_id} deleted" }
    else
      render json: { message: "User with ID #{user_id} not found" }, status: :not_found
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
