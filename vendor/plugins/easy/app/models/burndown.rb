class Burndown
  attr_accessor :iteration
  attr_accessor :width

  DEFAULT_WIDTH = 600

  def initialize(iteration, options = {})
    self.iteration = iteration
    self.width = options[:width] || DEFAULT_WIDTH
    self.width = 600 if width.to_i > 600
  end

  def to_png
    gruff = Gruff::Line.new(width.to_i)

    gruff.theme = {
      :colors => %w(grey darkorange),
      :marker_color => 'black',
      :background_colors => 'white'
    }

    gruff.data("Baseline", baseline_data)
    gruff.data("Actual", actual_data)

    gruff.minimum_value = 0
    gruff.y_axis_label = "Story Points"
    gruff.x_axis_label = "Day"
    gruff.labels = labels

    gruff.to_blob
  end

  def baseline_data
    points = iteration.initial_estimate
    duration = iteration.duration
    points_per_day = points.to_f / duration

    data = [points]
    iteration.duration.times do
      data << points -= points_per_day
    end
    data
  end

  def actual_data
    data = [iteration.initial_estimate]

    data_points = BurndownDataPoint.for_iteration(iteration).inject({}) do |data_points, point|
      data_points[point.date] = point.story_points
      data_points
    end

    today = [Date.today, iteration.end_date].min
    start = iteration.start_date
    previous_points = data.last
    (0...(today - start).to_i).each do |d|
      previous_points = data_points[start + d.days] || previous_points
      data << previous_points
    end

    data << iteration.story_points_remaining if today < iteration.end_date
    data
  end

  def labels
    labels = {}
    (1..iteration.duration).each { |v| labels[v] = v.to_s }
    labels
  end
end
