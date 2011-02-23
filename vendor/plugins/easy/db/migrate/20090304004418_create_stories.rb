class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.integer :project_id
      t.integer :iteration_id
      t.string :name
      t.text :content
      t.integer :estimate
      t.string :status, :default => 'pending'
      t.integer :priority, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
