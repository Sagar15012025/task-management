class CommentsController < ActionController::API
  before_action :get_comment, only: [ :update, :destroy ]
  before_action :get_task, only: [ :create, :update, :destroy ]

  def index
    comments = Comment.where(task_id: params[:task_id])
    render_success(comments)
  end

  def create
    comment = @task.comments.new(comment_params)
    if comment.save
      render_success(comment, :created)
    else
      render_error(comment.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    if @comment.update(comment_params)
      render_success(@comment)
    else
      render_error(@comment.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    @comment.destroy
    if @comment.destroyed?
      render_success(nil, :ok, "Comment with ID #{@comment.id} deleted")
    else
      render_error(@comment.errors.full_messages, :internal_server_error)
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :task_id, :user_id)
  end

  def get_task
    @task = Task.find_by(id: params[:task_id])
    if not @task
      render_error({ message: "Task with ID #{params[:id]} not found in project with ID #{params[:project_id]}" }, :not_found)
    end
  end

  def get_comment
    @comment = Comment.find_by(id: params[:id])
    render json: { message: "Comment with ID #{params[:id]} not found" }, status: :not_found if not @comment
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
