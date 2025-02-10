class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :description
      t.integer :status
      t.datetime :due_date
      t.references :project, null: true, foreign_key: { on_delete: :restrict }
      t.references :assignee, null: true, foreign_key: { to_table: :users, on_delete: :restrict }

      t.timestamps
    end
  end
end
