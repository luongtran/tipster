=begin
 tip_id
 author_id
 author_type
=end
class TipJournal
  EVENTS = [
      'created',
      'rejected',
      'published',
      'finished'
  ]
  #belongs_to :tip
  #belongs_to :author, polymorphic: true
end