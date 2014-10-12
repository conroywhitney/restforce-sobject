restforce-sobject
=================

Simple wrapper for Restforce gem.

Most documentation is in the comments.

An example of how to generate a dynamic form
----
```
<div class="form-group">
  <label class="col-md-2 control-label"><%= field.label %>:
    <%- unless field.nillable -%>
      <span class="required">* </span>
    <%- end -%>
  </label>
  <div class="col-md-10">
    <input type="text" class="form-control" name="property[<%= field.name %>]" value="<%= @property.send(field.name) if @property %>">
  </div>
</div>
```


Posting to Chatter
----
```
require 'uri'

class ChatterController < ApplicationController

  before_filter :require_salesforce

  def create
    object_id = params[:id]
    text = params[:text]

    encoded_text = URI::encode(text)
    content = { "body" => { "messageSegments" => [ { "type" => "Text", "text" => text }] }, "feedElementType" => "FeedItem", "subjectId" => object_id }

    @salesforce.api_post("/chatter/feed-elements?feedElementType=FeedItem&subjectId=#{object_id}&text=#{encoded_text}", content)

    redirect_to "/"
  end

end
```
