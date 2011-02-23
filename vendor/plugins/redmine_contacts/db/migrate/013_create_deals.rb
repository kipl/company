class CreateDeals < ActiveRecord::Migration
  def self.up
    rename_table :customers, :contacts
    
    Tagging.update_all({:container_type => 'Contact'}, {:container_type => 'Customer'})
    Comment.update_all({:commented_type => 'Contact'}, {:commented_type => 'Customer'})
    Attachment.update_all({:container_type => 'Contact'}, {:container_type => 'Customer'})   

    create_table :deals do |t|
      t.string :name
      t.text :background  
      t.integer :comments_count, :default => 0,  :null => false  
      t.integer :currency        
      t.decimal :price, :precision => 12, :scale => 2
      t.integer :price_type
      t.integer :duration

      t.references :project
      t.references :author
      
      t.timestamps
    end   
    
    create_table :contacts_deals, :force => true, :id => false  do |t|
      t.references :deal
      t.references :contact
    end     
    
    create_table :contacts_issues, :id => false do |t|
      t.column :issue_id, :integer, :default => 0, :null => false
      t.column :contact_id, :integer, :default => 0, :null => false
    end       
    
    add_column :contacts, :author_id, :integer, :default => 0,  :null => false    
    
  end

  def self.down      
    remove_column :contacts, :author_id
    
    drop_table :contacts_issues
    drop_table :contacts_deals
    drop_table :deals   
    
    rename_table :contacts, :customers
    
    Tagging.update_all({:container_type => 'Customer'}, {:container_type => 'Contact'})
    Comment.update_all({:commented_type => 'Customer'}, {:commented_type => 'Contact'})
    Attachment.update_all({:container_type => 'Customer'}, {:container_type => 'Contact'})   
    
  end
end
