# == Schema Information
#
# Table name: profiles
#
#  id                                 :integer          not null, primary key
#  user_id                            :integer          not null
#  civility                           :string(255)
#  birthday                           :date
#  address                            :string(255)
#  city                               :string(255)
#  country                            :string(255)
#  zip_code                           :string(255)
#  mobile_phone                       :string(255)
#  telephone                          :string(255)
#  favorite_betting_website           :string(255)
#  know_website_from                  :string(255)
#  secret_question                    :integer
#  answer_secret_question             :string(255)
#  received_information_from_partners :boolean          default(FALSE)
#  created_at                         :datetime
#  updated_at                         :datetime
#

class Profile < ActiveRecord::Base
  # TODO, if birthday is required so do we need to validate the age of user ?

  DEFAULT_BIRTHDAY = '1990-01-01'
  KNOW_WEBSITE_FROM_LIST = %w(other sponsoring advertising social_network)

  # If we have more questions, please add them at the bottom of the list
  SQ_BORN_CITY = 0
  SQ_COLOR_PREFER = 1
  SQ_PET_NAME = 2
  SQ_FAVORITE_ACTOR_OR_SINGER = 3
  SQ_MOTHER_MAIDEN_NAME = 4

  SECRET_QUESTIONS_MAP = {
      SQ_BORN_CITY => 'What is your born city?',
      SQ_COLOR_PREFER => 'What is your color preferred?',
      SQ_PET_NAME => 'What is the name of your pet?',
      SQ_FAVORITE_ACTOR_OR_SINGER => 'What is your actor or favorite singer?',
      SQ_MOTHER_MAIDEN_NAME => 'What is the maiden name of your mother?'
  }

  # ==============================================================================
  # ASSOCIATIONS
  # ==============================================================================
  belongs_to :user

  # ==============================================================================
  # VALIDATIONS
  # ==============================================================================

  validates_date :birthday, :before => lambda { 16.years.ago }, allow_blank: true
  validates :civility, :secret_question, :answer_secret_question, :mobile_phone, :birthday, :presence => true
  validates_inclusion_of :know_website_from, :in => KNOW_WEBSITE_FROM_LIST
  validates_inclusion_of :secret_question, :in => SECRET_QUESTIONS_MAP.keys

  validates_format_of :mobile_phone, :telephone, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/, allow_blank: true
  # ==============================================================================
  # CALLBACKS
  # ==============================================================================

  class << self
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def selected_secret_question
    SECRET_QUESTIONS_MAP[self.secret_question]
  end

  # recovery password by secret question
  def valid_secret_question?(secret_question)
    self.secret_question == secret_question
  end

  private

end
