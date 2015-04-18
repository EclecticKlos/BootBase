class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string      :name
      t.integer     :relevance_vote
      t.boolean     :temp_user_voted
      t.belongs_to  :project, index: true

      t.timestamps
    end
  end
end
