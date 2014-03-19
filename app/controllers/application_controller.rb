class ApplicationController < ActionController::Base
  layout :find_layout
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  helper_method :tipster_ids_in_cart

  # Define 3 helper methods: current_{subscriber|tipster|admin}
  [Tipster, Admin, Subscriber].each do |klass|
    method_name = "current_#{klass.name.downcase}"
    define_method method_name do
      if current_account && current_account.rolable.is_a?(klass)
        current_account.rolable
      else
        nil
      end
    end

    helper_method method_name

    define_method "authenticate_#{klass.name.downcase}" do
      if !account_signed_in?
        redirect_to_sign_in(klass)
      elsif !current_account.rolable.is_a?(klass)
        sign_out current_account
      end
    end
  end

  protected

  def current_ability
    @current_ability ||= Ability.new(current_account)
  end

  def tipster_required
    if account_signed_in? && !current_tipster
      sign_out current_account
    end
  end

  def admin_required
    if account_signed_in? && !current_admin
      sign_out current_account
    end
  end

  def subscriber_required
    if account_signed_in? && !current_subscriber
      sign_out current_account
    end
  end

# Render bad request(if: invalid params, etc ...)
  def render_400
    render nothing: true, status: 400
  end

  def render_404
    render nothing: true, status: 404
  end

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  rescue I18n::InvalidLocale => e
    I18n.locale = I18n.default_locale
  end

  def change_locale(lang)
    session[:locale] = lang
  end

# Clear and create new cart
  def initial_cart_session
    session[:cart] = {}
    session[:cart][:tipster_ids] = []
  end

  def add_tipster_to_cart(tipster_id)
    session[:cart][:tipster_ids] << tipster_id.to_s
  end

  def remove_tipster_from_cart(tipster_id)
    session[:cart][:tipster_ids].delete(tipster_id.to_s)
  end

  def reset_cart_session
    if current_subscriber && current_subscriber.subscription
      current_subscriber.subscription.inactive_tipsters.each do |tipster|
        add_tipster_to_cart(tipster.id) unless  tipster_ids_in_cart.include?(tipster.id.to_s)
      end
      current_subscriber.subscription.active_tipsters.each do |tipster|
        remove_tipster_from_cart(tipster.id) if tipster_ids_in_cart.include?(tipster.id.to_s)
      end
    end
  end

  def empty_cart_session
    session[:cart] = nil
  end

# Return an array of tipster's id in cart from session
  def tipster_ids_in_cart
    initial_cart_session if session[:cart].nil?
    session[:cart][:tipster_ids].uniq
  end

  def empty_subscribe_session
    empty_cart_session
    session[:plan_id] = nil
    session[:using_coupon] = nil
    session[:step] = nil
    session[:tipster_first] = nil
    session[:failed_add_tipster_id] = nil
    # Maybe clear more session vars: coupon code, payment info ...
  end

# Return current plan
  def selected_plan
    if session[:plan_id]
      Plan.find_by_id(session[:plan_id])
    elsif current_subscriber && current_subscriber.subscription
      session[:plan_id] = current_subscriber.subscription.plan.id
      current_subscriber.subscription.plan
    else
      nil
    end
  end

  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation)
  end

  def redirect_to_sign_in(klass)
    if klass == Subscriber
      flash[:sign_in_box] = true
      redirect_to root_url
    elsif klass == Tipster
      redirect_to backoffice_sign_in_url, alert: 'You need to signed in before continue'
    end
  end

  private
  def find_layout
    'backoffice' if self.class.name.split("::").first == 'Backoffice'
  end

end
