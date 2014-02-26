module ApplicationHelper
  def my_devise_error_messages!
    return "" if resource.errors.empty?
    messages = ""
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

  def set_current_register_step(step_name)
    @current_step == step_name ? 'active' : ''
  end

  def payment_methods_for_select
    options = []
    Payment::PAYMENT_METHODS.each_with_index do |p_m, index|
      options << [p_m.capitalize, index]
    end
    options
  end

  def platforms_for_select
    options = []
    Tip::BET_BOOKMARKERS.each do |pf|
      options << [pf.titleize, pf]
    end
    options
  end

  def query_params
    request.query_parameters
  end

  # Detemine the my_account path for two resources: subscriber or tipster
  def my_account_path_for(user)
    if user.is_a? Tipster
      backoffice_my_account_path
    elsif user.is_a? Subscriber
      my_account_path
    end
  end

  # Detemine the change_password path for two resources: subscriber or tipster
  def change_password_path_for(user)
    if user.is_a? Tipster
      backoffice_change_password_path
    elsif user.is_a? Subscriber
      change_password_path
    end
  end
end
