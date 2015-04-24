class CreateProjectsTags < ActiveRecord::Migration
  def change
    create_table :projects_tags do |t|
      t.belongs_to  :project
      t.belongs_to  :tag

      t.timestamps
    end
  end
end
