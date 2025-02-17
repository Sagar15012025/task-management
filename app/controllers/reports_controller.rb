class ReportsController < ActionController::API
  include ResponseHelper

  def status
    report = Report.find_by(file_id: params[:file_id])

    if not report
      render_error({ message: "Report with ID #{params[:file_id]} not found" }, :not_found)
      return
    end

    file_path = report_file_path(params[:file_id]) if report.status == "completed"
    message = report.status == "completed" ? "Report generated" : "Report not generated"
    render_success({ message: message, file_path: file_path, current_status: report.status }.compact) # compact - removes nil values
  end

  private

  def report_file_path(file_id)
    "/home/sagar-tagalys/Documents/SampleProjects/task-management/report/pending_tasks_report_#{file_id}.csv"
  end
end
