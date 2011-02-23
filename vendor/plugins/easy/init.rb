require 'redmine'
require 'dispatcher'
require 'project_patch'
require 'user_patch'

Redmine::Plugin.register :easy_agile do
  name 'Redmine Easy Agile plugin'
  author 'Sphere Consulting Inc.'
  description 'Simple scrum board for agile teams'
  version '1.0.3'
  url 'http://github.com/SphereConsultingInc/easy_agile'
  author_url 'http://sphereinc.com'

  project_module :easy_agile do
    permission :easy_agile_manage_iterations, :iterations => [:index, :new, :create, :show, :edit, :update, :planned, :finished]
    permission :easy_agile_view_home,       :easy_agile => [:show]
    permission :easy_agile_manage_stories, :stories => [:index, :new, :create, :show, :edit, :update, :backlog]
    permission :easy_agile_manage_acceptance_criteria, :acceptance_criteria => [:create, :edit, :update, :destroy]
    permission :easy_agile_manage_story_team_members, :story_team_members => [:create, :destroy]
  end

  Dispatcher.to_prepare do
    Project.send(:include, ProjectPatch) unless Project.included_modules.include? ProjectPatch
    User.send(:include, UserPatch) unless User.included_modules.include? UserPatch
    MyController.send(:include, MyControllerPatch) unless MyController.included_modules.include? MyControllerPatch
  end

  # observer
  ActiveRecord::Base.observers << :acceptance_criterion_observer << :story_action_observer

  menu :project_menu, :easy_agile, { :controller => 'easy_agile', :action => 'show' }, :caption => 'Easy Agile', :before => :calendar, :param => :project_id

  # feature
  Mime::Type.register "text/plain", :feature

  # cretiria inflections
  ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular 'criterion', 'criteria'
  end

end
