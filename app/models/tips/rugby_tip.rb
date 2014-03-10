# == Schema Information
#
# Table name: tips
#
#  id           :integer          not null, primary key
#  author_id    :integer
#  author_type  :string(255)
#  event        :string(255)      not null
#  expire_at    :string(255)      not null
#  platform     :string(255)      not null
#  bet_type     :integer          not null
#  odds         :float            not null
#  selection    :integer          not null
#  line         :float
#  advice       :text             not null
#  stake        :float            not null
#  amount       :integer          not null
#  correct      :boolean          default(FALSE)
#  status       :integer          not null
#  free         :boolean          default(FALSE)
#  published_by :integer
#  published_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class RugbyTip < Tip

end
