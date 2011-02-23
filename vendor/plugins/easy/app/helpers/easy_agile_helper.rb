module EasyAgileHelper
  def ea_tabs
    [{:id => 'easy_agile', :path => :project_easy_agile, :label => :dashboard},
     {:id => 'stories', :path => :backlog_project_stories,  :label => :backlog},
     {:id => 'iterations', :path => :project_iterations, :label => :iteration_plural},
    ]
  end
end
