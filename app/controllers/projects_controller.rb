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
    project = Rails.cache.fetch("project_#{project_id}", expires_in: 12.hours) do
      Project.find(project_id)
    end

    if project
      render json: project
    else
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
    end
  end

  def update
    project_id = params[:id]
    if project = Project.find(project_id)
      if project.update(project_params)
        Rails.cache.delete("project_#{project_id}")
        render json: project
      else
        render json: project.errors.full_messages, status: :unprocessable_entity
      end
    else
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
    end
  end

  def destroy
    project_id = params[:id]
    if project = Project.find(project_id)
      project.destroy
      if project.destroyed?
        Rails.cache.delete("project_#{project_id}")
        render json: { message: "Project with ID #{project_id} deleted" }
      else
        render json: { message: "Project with ID #{project_id} not deleted" }, status: :internal_server_error
      end
    else
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
    end
  end

  private
  def project_params
    params.require(:project).permit(:name, :description, :assignee_id)
  end
end
