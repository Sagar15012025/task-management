require "logger"

class UsersController < ActionController::API
  before_action :log_start
  after_action :log_end
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def initialize
    @logger = Logger.new(log_file_path)
  end

  def index
    render_success(User.all)
  end

  def create
    user = User.new(user_params)
    if user.save
      render_success(user, :created)
    else
      render_error(user.errors.full_messages, :unprocessable_entity)
    end
  end

  def show
    render_success(user_data(User.find(params[:id])))
  end

  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render_success(user)
    else
      render_error(user.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    if user.destroyed?
      render_success({ message: "User with ID #{params[:id]} deleted" })
    else
      render_error({ message: "User with ID #{params[:id]} not deleted" }, :internal_server_error)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def record_not_found(exception)
    log_error("User with ID #{params[:id]} not found: #{exception.message}")
    render_error({ message: "User with ID #{params[:id]} not found" }, :not_found)
  end

  def log_start
    log_info("Started UsersController##{action_name} with params #{params}")
  end

  def log_end
    log_info("Completed UsersController##{action_name}")
  end

  def log_file_path
    "/home/sagar-tagalys/Documents/SampleProjects/task-management/task-management.log"
  end

  def log_info(message)
    @logger.info("#{Date.today}\t#{Time.zone.now}\tINFO\t#{message}")
  end

  def log_error(message)
    @logger.error(message)
  end

  def user_data(user)
    { id: user.id, name: user.name, email: user.email, password: user.password }
  end

  def render_success(resource = nil, status = :ok, message = "Success")
    response = { message: message }
    response[:data] = resource if resource
    render json: response, status: status
  end

  def render_error(errors, status)
    render json: { errors: errors }, status: status
  end
end
