require "csv"

class PendingTaskReport
  include Sidekiq::Job
  include Sidekiq::Worker

  def perform(file_id, user_ids)
    generate_csv(file_id, user_ids)
  end

  private

  def generate_csv(file_id, user_ids)
    report = Report.find_by(file_id: file_id)
    report.update(status: "processing")

    sleep 30

    user_ids = User.pluck(:id) if user_ids.blank?
    tasks = Task.where(status: "pending", assignee_id: user_ids)
    file_name = "/home/sagar-tagalys/Documents/SampleProjects/task-management/report/pending_tasks_report_#{file_id}.csv"
    begin
      CSV.open(file_name, "w") do |csv|
        csv << [ "Title", "Description", "Project", "Created Date", "Due Date", "Assignee" ]
        tasks.each do |task|
          csv << [ task.title, task.description, task.project.name, task.created_at, task.due_date, task.assignee.name ]
        end
      end
      report.update(status: "completed") if report
    rescue => e
      report.update(status: "failed", error_message: e.message) if report
      raise e
    end
  end
end
