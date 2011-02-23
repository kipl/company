class Tagging < ActiveRecord::Base
  unloadable
  belongs_to :container, :polymorphic => true
  belongs_to :tag
  
end
