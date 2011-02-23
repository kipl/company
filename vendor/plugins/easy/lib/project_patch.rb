require_dependency 'project'

module ProjectPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      has_many :iterations, :dependent => :destroy
      has_many :stories, :dependent => :destroy
      has_many(:available_stories,
               :class_name => 'Story',
               :conditions => 'iteration_id IS NULL')
    end
  end

  module InstanceMethods

    def priorities=(priorities)
      priorities.each_pair do |id, priority|
        stories.update(id, :priority => priority)
      end
    end

  end
end

Project.send(:include, ProjectPatch)
