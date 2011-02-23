class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings, :id => false do |t|
      t.column :tag_id, :integer
      t.column :container_id, :integer
      t.column :container_type, :string
    end

    add_index :taggings, [:container_id, :container_type], :name => "taggings_ids", :unique => true 

  end


  def self.down
    drop_table :taggings
  end
end
