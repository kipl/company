class Moa < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :contact
  belongs_to :customer
end
