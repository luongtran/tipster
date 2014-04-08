class TipJournal < ActiveRecord::Base

  # <Tipster> has created a new tip: <Match name> at <time>
  # <Admin x> has approved and published a tip at <time>
  # <Admin y> has rejected the tip <Match name> at <time>
  # <Admin y> has finished the tip <Match name> at <time>
  EVENTS = [
      EVENT_CREATED = 'created',
      EVENT_REJECTED = 'rejected',
      EVENT_PUBLISHED = 'published',
      EVENT_FINISHED = 'finished'
  ]

  belongs_to :tip
  belongs_to :author, polymorphic: true

  validates_presence_of :tip, :author
  validates_inclusion_of :event, in: EVENTS

  delegate :full_name, to: :author, prefix: true
  class << self
    # Dynamically create methods: write_event_<event_name>
    # Params: tip(Tip), author(Tipster|Admin)
    EVENTS.each do |event|
      define_method "write_event_#{event}" do |tip, author|
        create(
            event: event,
            tip: tip,
            author: author,
            author_type: author.class.name
        )
      end
    end
  end
end