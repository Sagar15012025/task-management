class TasksController < ActionController::API
  include ResponseHelper

  before_action :validate_project, only: [ :index, :create, :show, :update, :destroy, :status, :overdue ]
  before_action :get_project, only: [ :create, :update ]
  before_action :get_task, only: [ :show, :update, :destroy ]

  def index
    tasks = Task.where(project_id: params[:project_id])
    render json: tasks
  end

  def create
    task = @project.tasks.new(task_params)
    if task.save
      render_success(task, :created)
    else
      render_error(task.errors.full_messages, :unprocessable_entity)
    end
  end

  def show
    render_success(@task)
  end

  def update
    if @task.update(task_params)
      render_success(@task)
    else
      render_error(@task.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    @task.destroy
    if @task.destroyed?
      render_success({ message: "Task with ID #{params[:id]} deleted" })
    else
      render_error(@task.errors.full_messages, :internal_server_error)
    end
  end

  def status
    status = params[:status]

    if not %w[pending active completed].include?(status)
      render_error({ message: "Invalid status value" }, :unprocessable_entity)
      return
    end

    tasks = Task.where(project_id: params[:project_id], status: status)
    render_success(tasks)
  end

  def overdue
    tasks = Task.where(project_id: params[:project_id]).where("due_date < ?", Date.today)
    render_success(tasks)
  end

  def report
    user_ids = params[:user_ids]
    file_id = SecureRandom.uuid
    report = Report.new(file_id: file_id)
    if report.save
      job_id = PendingTaskReport.perform_in(1.minutes, file_id, user_ids)
      report = Report.find_by(file_id: file_id)

      if report.update(job_id: job_id)
        render_success({ message: "Report generation initiated.", file_id: file_id, job_id: job_id })
      else
        job = Sidekiq::ScheduledSet.new.find_job([ job_id ])
        job.delete

        render_error({ error: "Report generation failed. Please retry." }, :internal_server_error)
      end
    else
      render_error({ error: "Report generation failed. Please retry." }, :internal_server_error)
    end
  end

  private

  def get_project
    @project = Project.find(params[:project_id])
  end

  def get_task
    @task = Task.find_by(id: params[:id], project_id: params[:project_id])
    if not @task
      render_error({ message: "Task with ID #{params[:id]} not found in project with ID #{params[:project_id]}" }, :not_found)
    end
  end

  def validate_project
    if not Project.exists?(params[:project_id])
      render_error({ message: "Project with ID #{params[:project_id]} not found" }, :not_found)
    end
  end

  def task_params
    params.require(:task).permit(:title, :description, :due_date, :project_id, :assignee_id)
  end
end
