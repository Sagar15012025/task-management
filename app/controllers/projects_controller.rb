class ProjectsController < ActionController::API
  def index
    projects = Project.all
    render json: projects
  end

  def create
    project = Project.new(project_params)
    if project.save
      render json: project, status: :created
    else
      render json: project.errors, status: :unprocessable_entity
    end
  end

  def show
    project_id = params[:id]
    if project = Project.where(id: project_id).first
      render json: project
    else
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
    end
  end

  def update
    project_id = params[:id]
    if project = Project.where(id: project_id).first
      project.update(project_params)
      render json: project
    else
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
    end
  end

  def destroy
    project_id = params[:id]
    if project = Project.where(id: project_id).first
      project.destroy
      render json: { message: "Project with ID #{project_id} deleted" }
    else
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
    end
  end

  private
  def project_params
    params.require(:project).permit(:name, :description, :assignee_id)
  end
end
