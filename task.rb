class Task < Sobject

  STATES = ["Not Started", "In Progress", "Waiting on someone else", "Completed", "Deferred"]

  PRIORITIES = ["Low", "Normal", "High", "Urgent"]

  def self.table
    return "Task"
  end

  def self.fields
    return "Id, Subject, Description, Status, Priority, CreatedDate, WhatId, WhoId, OwnerId"
  end

  def self.open
    return Task.all("Status <> 'Completed'")
  end

  def self.for(reference_id)
    return Task.all("WhatId='#{reference_id}'")
  end

  def self.mine(owner_id)
    # use Chatter.current_user.id in this method
    return Task.all("OwnerId='#{owner_id}' AND Status <> 'Completed'")
  end

  def mine?(owner_id)
    # use Chatter.current_user.id in this method
    return self.OwnerId == owner_id
  end

  def reference_id
    return self.WhatId
  end

  def title
    return self.subject
  end

  def date
    return Time.parse(self.CreatedDate)
  end

end
