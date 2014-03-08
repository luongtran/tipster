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

  def subscriber_required
    if account_signed_in? && !current_subscriber
      sign_out current_account
    end
  end

# Render bad request(if: invalid params, etc ...)
  def render_400
    render nothing: true, status: 400
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

  def reset_cart_session
    if current_subscriber && current_subscriber.subscription

      current_subscriber.subscription.inactive_tipsters.each do |tipster|
        session[:cart][:tipster_ids] << tipster.id.to_s unless session[:cart][:tipster_ids].include? tipster.id.to_s
      end
      current_subscriber.subscription.active_tipsters.each do |tipster|
        session[:cart][:tipster_ids].delete(tipster.id.to_s) if session[:cart][:tipster_ids].include? tipster.id.to_s
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
    # Maybe clear more session vars: coupon code, payment info ...
  end

  def selected_plan
    if session[:plan_id]
      Plan.find_by(id: session[:plan_id])
    end
  end

  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation)
  end

  private
  def find_layout
    'backoffice' if self.class.name.split("::").first == 'Backoffice'
  end

end
