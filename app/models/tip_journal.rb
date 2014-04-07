class TipJournal < ActiveRecord::Base

  # <Tipster> has created a new tip: <Match name> at <time>
  # <Admin x> has approved and published a tip at <time>
  # <Admin y> has rejected the tip <Match name> at <time>
  # <Admin y> has finished the tip <Match name> at <time>

  EVENT_CREATED = 'created'
  EVENT_REJECTED = 'rejected'
  EVENT_PUBLISHED = 'published'
  EVENT_FINISHED = 'finished'

  belongs_to :tip
  belongs_to :author, polymorphic: true

  validates_presence_of :tip, :author
end