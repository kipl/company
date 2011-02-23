class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.column :subject, :string
      t.column :content, :text
      t.references :source, :polymorphic => true
      t.references :author

      t.timestamps
    end
    
    rename_column :contacts, :notes, :background
    
    
    Comment.find(:all, :conditions => ["commented_type = 'Contact' OR commented_type = 'Deal'"]).each do |comment|
      note = Note.new
      note.content = comment.comments 
      note.source_type = comment.commented_type
      note.source_id = comment.commented_id
      note.author_id = comment.author_id
      note.created_at = comment.created_on  
      note.save
    end  
    
    Attachment.find(:all, :conditions => ["(container_type = 'Contact' OR container_type = 'Deal') and description <> 'avatar'"]).each do |att|  
      note = Note.new    
      note.content = att.description.blank? ? att.filename : att.description
      note.source_type = att.container_type
      note.source_id = att.container_id
      note.author_id = att.author_id
      note.created_at = att.created_on  
      note.save
 
      att.container_type = 'Note'
      att.container_id = note.id
      att.save
    end            
    
  end

  def self.down
    drop_table :notes 
    rename_column :contacts, :background, :notes
  end
end
