module ApplicationHelper
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
