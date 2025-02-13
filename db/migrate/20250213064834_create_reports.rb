class CreateReports < ActiveRecord::Migration[8.0]
  def up
    create_table :reports do |t|
      t.string :job_id
      t.string :file_id

      t.timestamps
    end

    execute <<-SQL
      ALTER TABLE reports ADD COLUMN status ENUM('pending', 'processing', 'completed', 'failed') NOT NULL DEFAULT 'pending'
    SQL
  end

  def down
    drop_table :reports
  end
end
