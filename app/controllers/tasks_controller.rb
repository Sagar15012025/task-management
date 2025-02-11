class TasksController < ActionController::API
  def index
    tasks = Task.all
    render json: tasks
  end

  def create
    task = Task.new(task_params)
    if task.save
      render json: task, status: :created
    else
      render json: task.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    task_id = params[:id]
    if task = Task.where(id: task_id).first
      render json: task
    else
      render json: { message: "Task with ID #{task_id} not found" }, status: :not_found
    end
  end

  def update
    task_id = params[:id]
    if task = Task.where(id: task_id).first
      if task.update(task_params)
        render json: task
      else
        render json: task.errors.full_messages, status: :unprocessable_entity
      end
    else
      render json: { message: "Task with ID #{task_id} not found" }, status: :not_found
    end
  end

  def destroy
    task_id = params[:id]
    if task = Task.where(id: task_id).first
      task.destroy
      if task.destroyed?
        render json: { message: "Task with ID #{task_id} deleted" }
      else
        render json: task.errors.full_messages, status: :internal_server_error
      end
    else
      render json: { message: "Task with ID #{task_id} not found" }, status: :not_found
    end
  end

  private
  def task_params
    params.require(:task).permit(:title, :description, :due_date, :project_id, :assignee_id)
  end
end
