class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.integer :current_status
      t.references :assignee, null: true, foreign_key: { to_table: :users, on_delete: :restrict }

      t.timestamps
    end
  end
end
