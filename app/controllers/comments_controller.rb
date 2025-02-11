class CommentsController < ActionController::API
  def index
    comments = Comment.all
    render json: comments
  end

  def create
    comment = Comment.new(comment_params)
    if comment.save
      render json: comment, status: :created
    else
      render json: comment.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    comment_id = params[:id]
    if comment = Comment.where(id: comment_id).first
      render json: comment
    else
      render json: { message: "Comment with ID #{comment_id} not found" }, status: :not_found
    end
  end

  def update
    comment_id = params[:id]
    if comment = Comment.where(id: comment_id).first
      if comment.update(comment_params)
        render json: comment
      else
        render json: comment.errors.full_messages, status: :unprocessable_entity
      end
    else
      render json: { message: "Comment with ID #{comment_id} not found" }, status: :not_found
    end
  end

  def destroy
    comment_id = params[:id]
    if comment = Comment.where(id: comment_id).first
      comment.destroy
      if comment.destroyed?
        render json: { message: "Comment with ID #{comment_id} deleted" }
      else
        render json: comment.errors.full_messages, status: :internal_server_error
      end
    else
      render json: { message: "Comment with ID #{comment_id} not found" }, status: :not_found
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:title, :description, :due_date, :project_id, :assignee_id)
  end
end
