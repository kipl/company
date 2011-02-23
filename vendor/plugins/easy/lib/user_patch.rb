require_dependency 'user'

module UserPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      has_many :story_team_members
      has_many :stories, :through => :story_team_members
      has_many :story_actions
      has_many :stories_worked_on, :through => :story_actions, :source => 'story'
      has_many :iterations_worked_on, :through => :story_actions, :source => 'iteration'
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def active_iterations_worked_on
      iterations_worked_on.active.select do |iteration|
        self.projects.include?(iteration.project)
      end.uniq
    end

    def active_stories_worked_on
      active_iterations = active_iterations_worked_on
      stories_worked_on.delete_if do |story|
        ! active_iterations.include?(story.iteration)
      end
    end

    def recently_finished_iterations_worked_on
      iterations_worked_on.recently_finished.select do |iteration|
        self.projects.include?(iteration.project)
      end.uniq
    end

    def active_iterations
      Iteration.active.find_all_by_project_id(self.projects)
    end
  end
end

User.send(:include, UserPatch)

