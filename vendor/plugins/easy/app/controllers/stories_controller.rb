class StoriesController < EasyAgileCommonController
  before_filter :find_optional_project
  before_filter :get_iteration, :only => [:new, :create]
  before_filter :get_story, :only => [:edit, :update, :show, :estimate]
  before_filter :new_story, :only => [:new, :create]

  helper :easy_agile


  def backlog
    @has_tabs = true
    if @project.stories.backlog.empty?
      render :template => 'stories/backlog_guidance', :layout => 'ea_base'
      return
    end
    render :template => 'stories/backlog', :layout => 'ea_base'
  end

  def show
    respond_to do |format|
      format.html do
        if params[:iteration_id]
          redirect_to [@project, @story], :status => 301
        end
      end

      format.feature
    end
  end

  def create
    if @story.save
      respond_to do |format|
        format.html do
          redirect_to [@project, @story]
        end

        format.js do
          head :created, :location => project_story_url(@project, @story)
        end
      end

    elsif @story.iteration_id?
      @iteration = @story.iteration
      render(:status => :unprocessable_entity,
             :template => 'stories/new_with_iteration')
    else
      render(:status => :unprocessable_entity,
             :template => 'stories/new_with_project')
    end
  end

  def estimate
    @body_classes = [controller_name, 'iteration_planning']
    render :partial => 'stories/story', :object => @story
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        get_iteration
        render :json => @iteration.stories.to_json(:only => [:status, :id])
      end
    end
  end

  def new
    @story.content = "As a
I want
So that "

    if @iteration
      render :template => 'stories/new_with_iteration'
    elsif @project
      render :template => 'stories/new_with_project'
    else
      render :template => 'stories/new_guidance'
    end
  end

  def update
    if params[:iteration_id]
      @story.update_attributes! params[:story]

      respond_to do |format|
        format.html do
          if params[:story][:status]
            redirect_to project_iteration_url(@project, params[:iteration_id])
          else
            redirect_to [@project, @story]
          end
        end

        format.js do
          head :ok
        end
      end

    else
      @story.update_attributes! params[:story]
      redirect_to [@project, @story]
    end

  rescue ActiveRecord::RecordInvalid => e
    render :template => 'stories/edit'
  end

  def has_tabs?
    @has_tabs
  end

  protected

  def get_iteration
    if params[:iteration_id] && @project
      @iteration = @project.iterations.find(params[:iteration_id])
    end
  end

  def get_story
    @story = @project.stories.find(params[:id])
  end

  def new_story
    if @iteration
      @story = @iteration.stories.build(params[:story])
    elsif @project
      @story = @project.stories.build(params[:story])
    else
      @story = Story.new
    end
  end

end
