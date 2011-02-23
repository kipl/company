class IterationsController < EasyAgileCommonController
  before_filter :find_optional_project
  before_filter :get_iterations, :only => [:index]
  before_filter :get_finished_iterations, :only => [:finished]
  before_filter :get_pending_iterations, :only => [:planned]
  before_filter :get_iteration, :only => [:edit, :show, :update]
  before_filter :new_iteration, :only => [:new, :create]
  before_filter :get_stories, :only => [:edit, :new]

  helper :stories

  def create
    @iteration.save_with_planned_stories_attributes! params[:stories]
    redirect_to [@project, @iteration]

  rescue ActiveRecord::RecordInvalid => e
    @stories = @iteration.planned_stories
    render :template => 'iterations/new'
  end

  def new
    if @stories.empty?
      render :template => 'iterations/new_guidance'
    end
  end

  def update
    @iteration.attributes = params[:iteration]
    @iteration.save_with_planned_stories_attributes! params[:stories]
    redirect_to [@project, @iteration]

  rescue ActiveRecord::RecordInvalid => e
    @stories = e.record.planned_stories
    render :template => 'iterations/edit'
  end

  def show
    if @iteration.active?
      render :template => 'iterations/show_active'
    end
  end

  protected

  def get_iterations
    @iterations = @project.iterations.active
  end

  def get_pending_iterations
    @iterations = @project.iterations.pending
  end

  def get_finished_iterations
    @iterations = @project.iterations.finished
  end

  def get_iteration
    @iteration = @project.iterations.find(params[:id])
  end

  def get_stories
    @stories = @project.stories.assigned_or_available_for(@iteration)
  end

  def new_iteration
    @iteration = @project.iterations.build(params[:iteration])
  end
end
