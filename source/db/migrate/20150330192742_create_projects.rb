class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string      :title
      t.string      :description
      t.string      :user_project_code
      t.belongs_to  :user

      t.timestamps
    end
  end
end
