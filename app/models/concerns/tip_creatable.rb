module TipCreatable
  extend ActiveSupport::Concern

  included do
    has_many :tips
  end

end