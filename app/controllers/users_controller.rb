require "logger"

class UsersController < ActionController::API
  before_action :log_start
  after_action :log_end
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def initialize
    @logger = Logger.new("/home/sagar-tagalys/Documents/SampleProjects/task-management/task-management.log")
  end

  def index
    users = User.all
    render json: users
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    user = User.find(params[:id])
    render json: user
  end

  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render json: user
    else
      render json: user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    if user.destroyed?
      render json: { message: "User with ID #{params[:id]} deleted" }
    else
      render json: { message: "User with ID #{params[:id]} not deleted" }, status: :internal_server_error
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def record_not_found(exception)
    @logger.error("User with ID #{params[:id]} not found: #{exception.message}")
    render json: { message: "User with ID #{params[:id]} not found" }, status: :not_found
  end

  def log_start
    @logger.info("#{Date.today}\t#{Time.zone.now}\tINFO\tStarted UsersController##{action_name} with params #{params}")
  end

  def log_end
    @logger.info("Completed UsersController##{action_name}")
  end
end
