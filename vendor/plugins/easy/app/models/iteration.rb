class Iteration < ActiveRecord::Base
  # for use after failed save_with_planned_stories_attributes!
  attr_accessor :planned_stories

  attr_protected :project_id
  belongs_to :project
  has_many :stories
  has_many :burndown_data_points
  validates_presence_of :name, :duration, :project_id
  validates_uniqueness_of :name
  validates_numericality_of :duration,
    :greater_than_or_equal_to => 1,
    :less_than_or_equal_to => 60,
    :only_integer => true

  named_scope :active,
    :conditions => 'start_date IS NOT NULL AND (end_date IS NULL OR end_date > CURRENT_DATE)'
  named_scope :pending, :conditions => 'start_date IS NULL'
  named_scope :recently_finished,
    :conditions => 'end_date <= CURRENT_DATE AND end_date >= CURRENT_DATE - 7'
  named_scope :finished, :conditions => 'end_date <= CURRENT_DATE'

  def validate
    errors.add(:stories, "must be assigned") if stories.empty?

    if (start_date? && !initial_estimate.nil? && initial_estimate <= 0)
      errors.add(:stories, :not_estimated)
    end
  end

  def save_with_planned_stories_attributes!(attributes)
    Iteration.transaction do
      stories.clear # no dependent => :destroy or :delete_all

      self.planned_stories = project.stories.find(attributes.keys)

      planned_stories.each do |story|
        story_attributes = attributes[story.id.to_s]
        included = story_attributes.delete('include') == '1'

        if included
          story.attributes = story_attributes
          self.stories << story
        else
          story.update_attributes!(story_attributes)
        end
      end

      save!
    end
  end

  def name
    if attributes["name"]
      attributes["name"]
    elsif project
      "Iteration #{project.iterations.count + 1}"
    end
  end

  def to_s
    name || 'New Iteration'
  end

  def story_points_remaining
    stories.incomplete.inject(0) do |sum, st|
      sum + st.estimate.to_i
    end
  end

  def start
    unless active?
      self.update_attributes(
        :start_date => Date.today,
        :initial_estimate => story_points_remaining
      )
    end
  end

  def duration=(value)
    super value
    if value && start_date?
      self.end_date = start_date + value.to_i
    end
  end

  def start_date=(value)
    super value
    if value && duration?
      self.end_date = value + duration
    end
  end

  def days_remaining
    end_date - Date.today
  end

  def pending?
    !active?
  end

  def active?
    ! self.start_date.nil?
  end

  def finished?
    end_date? && end_date <= Date.today
  end

  def burndown(width = nil)
    options = {}
    options[:width] = width unless width.nil?
    Burndown.new(self, options)
  end

  def update_burndown_data_points
    return if ! active? || end_date <=  Date.today
    data_point = burndown_data_points.find_by_date(Date.today)
    if data_point
      data_point.update_attributes(:story_points => story_points_remaining)
    else
      burndown_data_points.create(
        :date => Date.today,
        :story_points => story_points_remaining
      )
    end
  end

  def self.update_burndown_data_points_for_all_active
    active.each do |iteration|
      iteration.update_burndown_data_points
    end
  end
end
