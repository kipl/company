class EasyAgileCommonController < ApplicationController
  layout 'ea_base'
  helper :easy_agile

  alias_method :tab_name, :controller_name

  def controller_name
    "easy_agile"
  end

  # show tabs in a layout?
  def has_tabs?
    true
  end
end
