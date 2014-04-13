class ApplicationController < ActionController::Base
  USER_TYPE = Subscriber.name
  protect_from_forgery with: :exception

  before_action :set_locale, :clean_session

  helper_method :tipster_ids_in_cart

  rescue_from Exception, :with => :write_log if Rails.env.production?

  # Define 3 helper methods: current_<subscriber|tipster|admin> to find current signed in user
  [Tipster, Admin, Subscriber].each do |klass|
    method_name = "current_#{klass.name.downcase}"
    define_method method_name do
      instance_variable_get("@current_#{klass.name.downcase}") ||
          if current_account && current_account.rolable.is_a?(klass)
            instance_variable_set(:"@current_#{klass.name.downcase}", current_account.rolable)
          else
            nil
          end
    end

    helper_method method_name

    # Define 3 methods: authenticate_<subscriber|tipster|admin> to check user signed in
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

  # Render bad request if: invalid params, etc ...
  def render_400
    render nothing: true, status: 400
  end

  def render_404
    render nothing: true, status: 404
  end

  def render_500
    respond_to do |format|
      format.js do
        render :json => 'Server Error'
      end
      format.html do
        render 'errors/500'
      end
    end
  end


  # Destroy session if a singed-in users access to a place not be for them
  def clean_session
    if account_signed_in?
      current_user = current_account.rolable
      if current_user.class.name != self.class::USER_TYPE
        sign_out current_account
      end
    end
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
    session[:tipster_first] = nil
    session[:failed_add_tipster_id] = nil
    session[:old_id] = nil
  end

# Return an array of tipster's id in cart from session
  def tipster_ids_in_cart
    initial_cart_session if session[:cart].nil?
    session[:cart][:tipster_ids].uniq
  end

  def total_tipster
    if current_subscriber && current_subscriber.subscription
      total = tipster_ids_in_cart.size + current_subscriber.subscription.tipsters_size
    else
      total = tipster_ids_in_cart.size
    end
    total
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
      Plan.find_by(id: session[:plan_id])
    elsif current_subscriber && current_subscriber.subscription && current_subscriber.subscription.plan
      session[:plan_id] = current_subscriber.subscription.plan.id
      current_subscriber.subscription.plan
    else
      nil
    end
  end

  def account_params
    params.require(:account).permit(:email, :password, :password_confirmation)
  end

  private

  def redirect_to_sign_in(klass)
    if klass == Subscriber
      flash[:sign_in_box] = true
      redirect_to root_url
    elsif klass == Tipster
      redirect_to backoffice_root_url, alert: 'You need to signed in before continue'
    elsif klass == Admin
      redirect_to admin_root_url, alert: 'You need to signed in before continue'
    else
      redirect_to root_url
    end
  end

  def load_subscribe_data
    @selected_plan = selected_plan
  end

  # Catch server errors and print to public/errors.txt
  def write_log(exception)
    Thread.new do
      File.open(File.join(Rails.root, 'public', 'errors.txt'), "a") do |f|
        f.puts "=====Error: #{exception.message}======#{Time.now} ==========================\n"
        f.puts(exception.backtrace.join("\n"))
        f.puts "=================================================================================\n"
      end
    end
    render_500
  end
end
