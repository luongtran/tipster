# == Schema Information
#
# Table name: tips
#
#  id           :integer          not null, primary key
#  tipster_id   :integer          not null
#  event        :string(255)      not null
#  platform     :integer          not null
#  bet_type     :integer          not null
#  odds         :float            not null
#  line         :float
#  selection    :integer          not null
#  advice       :text             not null
#  stake        :float            not null
#  liability    :float            not null
#  amount       :integer          not null
#  correct      :boolean          default(FALSE)
#  status       :integer          not null
#  published_by :integer
#  published_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class Tip < ActiveRecord::Base
end
