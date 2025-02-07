class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.integer :status
      t.references :user, null: true, foreign_key: { on_delete: :restrict }

      t.timestamps
    end
  end
end
