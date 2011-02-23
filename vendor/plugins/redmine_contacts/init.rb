          # Redmine contact plugin
require 'redmine'  
require 'contacts_issue_patch' 
require 'show_issue_contacts_hook'       
require 'contacts_wiki_macros'

RAILS_DEFAULT_LOGGER.info 'Starting Contact plugin for RedMine'

Redmine::Plugin.register :contacts do
  name 'Contacts plugin'
  author 'Kirill Bezrukov'
  description 'This is a plugin for Redmine that can be used to track basic contacts information'
  version '1.1.5'

  author_url 'mailto:kirill.bezrukov@gmail.com' if respond_to? :author_url

   
  
  project_module :contacts_module do
    permission :view_contacts, :contacts => [:show, 
                                             :index, 
                                             :live_search, 
                                             :contacts_notes, 
                                             :contacts_issues], :public => true
    permission :edit_contacts, :contacts => [:edit, 
                                               :update, 
                                               :new, 
                                               :create, 
                                               :add_attachment, 
                                               :add_note, 
                                               :destroy_note, 
                                               :edit_tags,
                                               :add_task, 
                                               :add_contact_to_issue, 
                                               :close_issue,
                                               :delete_own_notes]   
    permission :add_notes, :contacts =>  [:add_note, :delete_own_notes], :deals => [:add_note]                                        
    permission :delete_contacts, :contacts => [:destroy, 
                                               :destroy_contact_from_issue]
    permission :delete_deals, :deals => :destroy    
    
    permission :view_deals, :deals => [:index, :show], :public => true
    permission :edit_deals, :deals => [:new, 
                                       :create, 
                                       :edit, 
                                       :update,
                                       :add_attachment,
                                       :add_note,
                                       :destroy_note], :public => true
    
  end

  menu :project_menu, :contacts, {:controller => 'contacts', :action => 'index'}, :caption => :contacts_title, :param => :project_id
  # menu :project_menu, :deals, { :controller => 'deals', :action => 'index' }, :caption => :label_deal_plural, :param => :project_id
  
  menu :top_menu, :contacts, {:controller => 'contacts', :action => 'index'}, :caption => :contacts_title
  
  activity_provider :contacts, :default => false, :class_name => ['Note']  

  # activity_provider :contacts, :default => false   
end

