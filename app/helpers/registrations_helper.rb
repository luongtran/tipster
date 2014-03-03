module RegistrationsHelper
  def secret_questions_for_select
    options = []
    Subscriber::SECRET_QUESTIONS_MAP.each do |key, val|
      options << [val, key]
    end
    options
  end

  def know_website_from_for_select
    options = []
    Subscriber::KNOW_WEBSITE_FROM_LIST.each do |from|
      options << [from.titleize, from]
    end
    options
  end
end