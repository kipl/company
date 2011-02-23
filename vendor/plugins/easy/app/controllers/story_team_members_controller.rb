class StoryTeamMembersController < ApplicationController
  before_filter :find_optional_project
  before_filter :new_story_team_member, :only => [:create]
  before_filter :get_story_team_member, :only => [:destroy]

  helper :stories

  def create
    if @story_team_member.save
      redirect_to [
        @story_team_member.story.project,
        @story_team_member.story
      ]
    else
      @story = @story_team_member.story
      render :template => 'stories/show'
    end
  end

  def destroy
    @story_team_member.destroy
    redirect_to [
      @story_team_member.story.project,
      @story_team_member.story
    ]
  end

  protected

  def new_story_team_member
    @story_team_member =
      StoryTeamMember.new(params[:story_team_member].
        merge(:user => User.current))

  end

  def get_story_team_member
    @story_team_member =
      StoryTeamMember.find(params[:id],
      :conditions => ['user_id = ?', User.current.id])
  end
end
