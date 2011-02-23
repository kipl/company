class EasyAgileController < EasyAgileCommonController
  before_filter :find_optional_project

  helper :stories

  def show
    if @project.stories.empty?
      render :template => 'easy_agile/show_guidance'
    end
  end

  def my_page
  end
end
