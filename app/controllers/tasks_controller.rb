class TasksController < ActionController::API
  before_action :set_project, only: [ :create, :update ]

  def index
    tasks = Task.where(project_id: params[:project_id])
    render json: tasks
  end

  def create
    task = @project.tasks.new(task_params)
    if task.save
      render json: task, status: :created
    else
      render json: task.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    task_id = params[:id]
    project_id = params[:project_id]

    unless Project.exists?(project_id)
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
      return
    end

    unless Task.exists?(id: task_id, project_id: project_id)
      render json: { message: "Task with ID #{task_id} not found in project with ID #{project_id}" }, status: :not_found
      return
    end

    task = Task.find(task_id)
    render json: task
  end

  def update
    task_id = params[:id]
    project_id = params[:project_id]

    unless Project.exists?(project_id)
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
      return
    end

    unless Task.exists?(id: task_id, project_id: project_id)
      render json: { message: "Task with ID #{task_id} not found in project with ID #{project_id}" }, status: :not_found
      return
    end

    task = Task.where(id: task_id).first
    if task.update(task_params)
      render json: task
    else
      render json: task.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    task_id = params[:id]
    project_id = params[:project_id]

    unless Project.exists?(project_id)
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
      return
    end

    unless Task.exists?(id: task_id, project_id: project_id)
      render json: { message: "Task with ID #{task_id} not found in project with ID #{project_id}" }, status: :not_found
      return
    end

    task = Task.where(id: task_id).first
    task.destroy
    if task.destroyed?
      render json: { message: "Task with ID #{task_id} deleted" }
    else
      render json: task.errors.full_messages, status: :internal_server_error
    end
  end

  def status
    project_id = params[:project_id]
    status = params[:status]

    unless Project.exists?(project_id)
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
      return
    end

    unless [ "pending", "active", "completed" ].include?(status)
      render json: { message: "Invalid status value" }, status: :unprocessable_entity
      return
    end

    tasks = Task.where(project_id: project_id, status: status)
    render json: tasks
  end

  def overdue
    project_id = params[:project_id]

    unless Project.exists?(project_id)
      render json: { message: "Project with ID #{project_id} not found" }, status: :not_found
      return
    end

    tasks = Task.where(project_id: project_id).where("due_date < ?", Date.today)
    render json: tasks
  end

  def report
    user_ids = params[:user_ids]
    file_id = SecureRandom.uuid
    report = Report.new(file_id: file_id)
    if report.save
      job_id = PendingTaskReport.perform_in(1.minutes, file_id, user_ids)
      report = Report.find_by(file_id: file_id)

      if report.update(job_id: job_id)
        render json: { message: "Report generation initiated.", file_id: file_id, job_id: job_id }
      else
        # a better approach would be to retry update for a few times and then deleting the job
        #   - the job may have been completed by then
        #   - the job may still have been processing
        # an even better approach would be to save the job_id in Redis and later
        #   - later, when checking the status of the report, check if the job_id is present in the table
        #     - if yes, use that to check the status of the job
        #     - if no, check if the job_id is present in Redis and check the status of the job
        job = Sidekiq::ScheduledSet.new.find_job([ job_id ])
        job.delete

        render json: { error: "Report generation failed. Please retry." }, status: :internal_server_error
      end
    else
      render json: { error: "Report generation failed. Please retry." }, status: :internal_server_error
    end
  end

  private
  def set_project
    @project = Project.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :project_id, :assignee_id)
  end
end
