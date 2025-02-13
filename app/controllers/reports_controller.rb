class ReportsController < ActionController::API
  def status
    file_id = params[:file_id]
    if not Report.find_by(file_id: file_id)
      render json: { message: "Report with ID #{file_id} not found" }, status: :not_found
      return
    end

    report = Report.find_by(file_id: file_id)
    status = report.status

    if status == "completed"
      file_path = "/home/sagar-tagalys/Documents/SampleProjects/task-management/report/pending_tasks_report_#{file_id}.csv"
      render json: { message: "Report generated", file_path: file_path }
    else
      render json: { message: "Report not generated", current_status: status }
    end
  end

  private

  def job_in_progress?(jid)
    Sidekiq::Queue.all.any? { |queue| queue.any? { |job| job.jid == jid } } ||
      Sidekiq::Workers.new.any? { |_, _, work| work["payload"]["jid"] == jid }
  end

  def job_completed?(jid)
    !job_in_progress?(jid) && !Sidekiq::RetrySet.new.find { |job| job.jid == jid } &&
      !Sidekiq::DeadSet.new.find { |job| job.jid == jid }
  end
end
