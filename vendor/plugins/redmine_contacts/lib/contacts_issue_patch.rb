require_dependency 'issue'   
require_dependency 'issues_controller'
require_dependency 'dispatcher'
 
# Patches Redmine's Issues dynamically. Adds a relationship
# Issue +has_many+ to ArchDecisionIssue
# Copied from dvandersluis' redmine_resources plugin: 
# http://github.com/dvandersluis/redmine_resources/blob/master/lib/resources_issue_patch.rb
module ContactsIssuePatch   
  
  def self.included(base) # :nodoc: 
    
    base.extend(ClassMethods)
 
    base.send(:include, InstanceMethods)
    
    # Same as typing in the class
    base.class_eval do    
      unloadable # Send unloadable so it will not be unloaded in development
      has_and_belongs_to_many :contacts, :order => "last_name, first_name", :uniq => true
    end  
    
    
  end  
  
  module ClassMethods
  end

  module InstanceMethods
  end
  
end     

module MailerPatch
  module ClassMethods
  end

  module InstanceMethods
    def note_added(note, parent)
      redmine_headers 'X-Project' => note.source.project.identifier, 
                      'X-Notable-Id' => note.source.id,
                      'X-Note-Id' => note.id
      message_id note
      if parent
        recipients (note.source.watcher_recipients + parent.watcher_recipients).uniq
      else
        recipients note.source.watcher_recipients
      end
        
      subject "[#{note.source.project.name}] - #{parent.name + ' - ' if parent}#{l(:label_note_for)} #{note.source.name}"  
      
      body :note => note,   
           :note_url => url_for(:controller => note.source.class.name.pluralize.downcase, :action => 'show', :project_id => note.source.project, :id => note.source.id)
      render_multipart('note_added', body)
    end
    
    def issue_connected(issue, contact)
      redmine_headers 'X-Project' => contact.project.identifier, 
                      'X-Issue-Id' => issue.id,
                      'X-Contact-Id' => contact.id
      message_id contact
      recipients contact.watcher_recipients 
      subject "[#{contact.project.project.name}] - #{l(:label_issue_for)} #{contact.name}"  
      
      body :contact => contact,
           :issue => issue,
           :contact_url => url_for(:controller => contact.class.name.pluralize.downcase, :action => 'show', :project_id => contact.project, :id => contact.id),
           :issue_url => url_for(:controller => "issues", :action => "show", :id => issue)
      render_multipart('issue_connected', body)
      
    end
    
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end


module ContactsIssuesControllerPatch
  def self.included(base) # :nodoc: 
    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)

    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
      helper "contacts"   
      
    end
  end 

  module ClassMethods
  end  
  module InstanceMethods
    
    # def add_contact_relation   
    #   debugger
    #   @contact = Contact.new(params[:contact])
    #   @contact.issues = [@contact_issue]
    #   @contact.save if request.post?
    #   respond_to do |format|
    #     format.html { redirect_to :back }
    #     format.js do
    #       render :update do |page|
    #         page.replace_html 'contacts', :partial => 'issues/contacts', :locals => {:contact_issue => @contact_issue}
    #       end
    #     end
    #   end
    # rescue ::ActionController::RedirectBackError
    #   render :text => 'Contact added.', :layout => true
    # end
    
  end


end

Dispatcher.to_prepare do
  Issue.send(:include, ContactsIssuePatch)    
  Mailer.send(:include, MailerPatch) 
  IssuesController.send(:include, ContactsIssuesControllerPatch)  
end 

# IssuesController.send(:include, ContactsIssuesControllerPatch) 