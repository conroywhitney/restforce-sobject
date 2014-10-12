class Chatter < Sobject

  attr_accessor :feed_hash

  def self.for(resource_id)
    # chatter for a specific Salesforce resource (object)
    return client.api_get("/chatter/feeds/record/#{resource_id}/feed-elements").body.elements.collect { |feed_item| new(feed_item) }
  end

  def self.current_user
    # use /me call to determine info about authenticated user
    return client.api_get("/chatter/users/me").body
  end

  def user_name
    return self.actor.name
  end

  def user_image
    return self.actor.photo.smallPhotoUrl
  end

  def date
    return Time.parse(self.createdDate)
  end

  def display_text
    # it's difficult to find which string you want to display
    # try using debugger gem to inspect a single Chatter object

    # this one will work for comments
    return self.body.text if self.body.present? && self.body.text.present?

    # this one will work for tasks
    return self.header.text
  end

end
