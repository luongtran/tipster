if Rails.env.development?
  ActiveRecordQueryTrace.enabled = false
  ActiveRecordQueryTrace.level = :app # default
end