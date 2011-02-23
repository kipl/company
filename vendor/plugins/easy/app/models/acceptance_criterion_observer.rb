class AcceptanceCriterionObserver < ActiveRecord::Observer
  def after_save(acceptance_criterion)
    acceptance_criterion.story.update_status_from_acceptance_criteria
  end
end
