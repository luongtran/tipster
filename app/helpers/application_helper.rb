module ApplicationHelper
  def my_devise_error_messages!
    return "" if resource.errors.empty?

    messages  = ""

    if !resource.errors.empty?
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    end

    messages = messages
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation" class="alert alert-danger">
    <label>#{sentence}</label>
    <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-warning"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def tipster_ids_in_cart
    return [] if session[:cart].nil?
    session[:cart][:tipster_ids]
  end

  def set_current_register_step(step_name)
    @current_step == step_name ? 'active' : ''
  end
end
