class CreateIterations < ActiveRecord::Migration
  def self.up
    create_table :iterations do |t|
      t.integer :project_id
      t.string :name
      t.integer :duration
      t.integer :initial_estimate
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end

  def self.down
    drop_table :iterations
  end
end
