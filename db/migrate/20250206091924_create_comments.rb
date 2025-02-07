class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.string :content
      t.references :task, null: true, foreign_key: { on_delete: :restrict }
      t.references :user, null: true, foreign_key: { on_delete: :restrict }

      t.timestamps
    end
  end
end
