require_dependency 'my_controller'

module MyControllerPatch
  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      helper :stories
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end

MyController.send(:include, MyControllerPatch)

