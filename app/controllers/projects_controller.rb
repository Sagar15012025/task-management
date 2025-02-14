class ProjectsController < ActionController::API
  include CacheHelper

  before_action :get_project, only: [ :show, :update, :destroy ]

  def index
    render_success(Project.all)
  end

  def create
    project = Project.new(project_params)
    if project.save
      fetch_from_cache("project_#{project.id}") { project }
      render_success(project, :created)
    else
      render_error(project.errors.full_messages, :unprocessable_entity)
    end
  end

  def show
    render json: @project
  end

  def update
    if @project.update(project_params)
      delete_cache("project_#{@project.id}")
      fetch_from_cache("project_#{@project.id}") { @project }
      render_success(@project)
    else
      render_error(@project.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    @project.destroy
    if @project.destroyed?
      delete_cache("project_#{@project.id}")
      render_success({ message: "Project with ID #{params[:id]} deleted" }, nil, :ok)
    else
      render_error({ message: "Project with ID #{@project.id} not deleted" }, :internal_server_error)
    end
  end

  private

  def get_project
    @project = fetch_from_cache("project_#{params[:id]}") do
      Project.find_by(id: params[:id])
    end

    render_error({ message: "Project with ID #{params[:id]} not found" }, :not_found) unless @project
  end


  def project_params
    params.require(:project).permit(:name, :description, :assignee_id)
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
