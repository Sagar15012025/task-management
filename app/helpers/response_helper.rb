module ResponseHelper
  def render_success(resource = nil, status = :ok, message = "Success")
    response = { message: message }
    response[:data] = resource if resource
    render json: response, status: status
  end

  def render_error(errors, status)
    render json: { errors: errors }, status: status
  end
end
