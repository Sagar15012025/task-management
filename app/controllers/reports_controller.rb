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
end
