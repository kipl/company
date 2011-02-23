class Story < ActiveRecord::Base
  module Status
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    TESTING = "testing"
    COMPLETE = "complete"
  end

  attr_accessor :include
  belongs_to :iteration
  belongs_to :project

  has_many(:acceptance_criteria,
           :order => 'criterion',
           :dependent => :destroy)

  has_many :team_members, :class_name => 'StoryTeamMember'
  has_many :users, :through => :team_members

  default_scope :order => 'priority, created_at DESC'

  named_scope :assigned_or_available_for, lambda {|iteration|
    {
      :conditions => [
        'status = ? AND (iteration_id = ? OR iteration_id IS NULL)',
        'pending', iteration.id
      ]
    }
  }

  named_scope :backlog,
    :conditions => ['status = ? AND iteration_id IS NULL', 'pending']

  validates_presence_of :name, :content, :project_id
  validates_uniqueness_of :name, :scope => :project_id
  validates_numericality_of :estimate,
    :only_integer => true,
    :allow_nil => true,
    :greater_than_or_equal_to => 0,
    :less_than => 101

  def validate
    if iteration && project && (iteration.project_id != project_id)
      errors.add(:iteration_id, "does not belong to the story's project")
    end

    # iteration id changed on a story
    if iteration_id_changed? && !changes['iteration_id'][0].nil?
      errors.add(:iteration_id, "cannot be changed")
    end
  end

  named_scope :incomplete, :conditions => ['status != ?', 'complete']

  after_update :update_iteration_points

  def to_s
    name || "New Story"
  end

  def update_status_from_acceptance_criteria
    return if iteration.nil?
    if acceptance_criteria.uncompleted.empty?
      if (status == Status::PENDING || status == Status::IN_PROGRESS)
        users.clear
        self.update_attributes(:status => Status::TESTING)
      end
    elsif status == Status::TESTING || status == Status::COMPLETE
      users.clear
      self.update_attributes(:status => Status::IN_PROGRESS)
    end
  end

  private

  def update_iteration_points
    iteration.try(:update_burndown_data_points)
  end
end
