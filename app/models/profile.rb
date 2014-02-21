class Profile < ActiveRecord::Base
  # TODO, if birthday is required so do we need to validate the age of user ?

  DEFAULT_BIRTHDAY = '1900-01-01'
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

  validates_date :birthday, :message => 'birthday is invalid' #TODO, move to locale
  validates :civility, :secret_question, :answer_secret_question, :mobile_phone, :presence => true
  validates_inclusion_of :know_website_from, :in => KNOW_WEBSITE_FROM_LIST
  validates_inclusion_of :secret_question, :in => SECRET_QUESTIONS_MAP.keys

  # ==============================================================================
  # CALLBACKS
  # ==============================================================================

  before_validation :init_default_birthday

  class << self
  end

  # ==============================================================================
  # INSTANCE METHODS
  # ==============================================================================

  def selected_secret_question
    SECRET_QUESTIONS_MAP[self.secret_question]
  end

  private

  def init_default_birthday
    self[:birthday] ||= DEFAULT_BIRTHDAY
  end
end
