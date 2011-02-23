module ApplicationHelper

  def javascript_includes
    javascript_include_tag('jquery-1.3.2.min.js',
                           'jquery-ui-1.7.custom.min.js',
                           'jquery.form.js',
                           'application',
                           'flash',
                           'story',
                           'request',
                           'acceptance_criteria',
                           'iteration_planning',
                           'iteration_active',
                           'backlog_prioritisation',
                           :plugin => 'easy_agile')
  end

  def next_steps(&block)
    content = '<div id="next_steps"><h2>Next Steps</h2>'
    content += yield if block_given?
    content += '</div>'
  end

  def story_format(content)
    return nil if content.blank?
    items = content.split("\n")

    xml = Builder::XmlMarkup.new
    xml.ol do
      items.each do |item|
        xml.li do |li|
          li << h(item)
        end
      end
    end
  end

  def contextual_new_story_path
    if @iteration && !@iteration.new_record? && @iteration.pending?
      [:new, @project, @iteration, :story]
    elsif @project && !@project.new_record?
      [:new, @project, :story]
    else
      new_story_path
    end
  end

  def body_classes
    @body_classes ||= [controller.controller_name]
  end

  def render_flash
    return nil if flash.keys.empty?
    xml = Builder::XmlMarkup.new
    xml.div :class => 'flash' do
      flash.each do |type, message|
        next if message.blank?
        xml.div :class => type do
          xml.h2 type.to_s.titleize
          xml.p do |p|
            p << message
          end
        end
      end
    end
  end

end
